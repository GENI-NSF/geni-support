#!/usr/bin/ruby

require 'mysql'

#this script adds the following
#mmeidentity entry
#user and pdn for each imsi, referencing the mme created
#in this step, note that key is added with the UNHEX command

#to use, set imsis, realm, mme, hss, and apn as needed to match configuration and sim cards. max_mme and max_ue reference the existing number of entries in the db.

imsis=['001010000000001','001010000000002','001010000000003','001010000000004','001010000000005','001010000000006','001010000000007','001010000000008','001010000000009','001010000000010','001010000000011','001010000000012']
realm = '.donotdelete.ch-geni-net.instageni.gpolab.bbn.com'
mme = 'gpo-pc.donotdelete.ch-geni-net.instageni.gpolab.bbn.com'
hss = 'hss.donotdelete.ch-geni-net.instageni.gpolab.bbn.com'
apn = 'orbitA'
max_mme = 6 #number of existing mme entries in table mmeidentity
max_ue = 59 #number of existing UEs in table users

begin
	con = Mysql.new 'localhost', 'root', 'linux', 'oai_db'

	con.query("REPLACE INTO mmeidentity (`idmmeidentity`, `mmehost`, `mmerealm`, `UE-Reachability`) VALUES ('#{max_mme + 1}',  '#{mme}','#{realm}', '0')")

	imsis.each_with_index do |imsi, index|
	  puts "#{index + max_ue +1}" #due to existing entries in DB
	  puts "#{imsi}"
	  con.query("REPLACE INTO pdn (`id`, `apn`, `pdn_type`, `pdn_ipv4`, `pdn_ipv6`, `aggregate_ambr_ul`, `aggregate_ambr_dl`, `pgw_id`, `users_imsi`, `qci`, `priority_level`,`pre_emp_cap`,`pre_emp_vul`, `LIPA-Permissions`) VALUES ('#{index + max_ue + 1}',  '#{apn}','IPV4', '0.0.0.0', '0:0:0:0:0:0:0:0', '50000000', '100000000', '1',  '#{imsi}', '9', '15', 'DISABLED', 'ENABLED', 'LIPA-ONLY')")
	  con.query("REPLACE INTO users (`imsi`, `msisdn`, `imei`, `imei_sv`, `ms_ps_status`, `rau_tau_timer`, `ue_ambr_ul`, `ue_ambr_dl`, `access_restriction`, `mme_cap`, `mmeidentity_idmmeidentity`, `key`, `RFSP-Index`, `urrp_mme`, `sqn`, `rand`, `OPc`) VALUES ('#{imsi}',  '33638060010', NULL, NULL, 'PURGED', '120', '50000000', '100000000', '47', '0000000000', '#{max_mme + 1}', UNHEX('8BAF473F2F8FD09487CCCBD7097C6862'), '1', '0', '0', 0x00000000000000000000000000000000, '')")
	end

rescue Mysql::Error => e
  puts e.errno
  puts e.error

ensure
  con.close if con
end
