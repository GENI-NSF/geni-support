#!/bin/bash

IFTMPFILE=`mktemp`
SWITCHNAME="br0"
IFINFO=/tmp/InterfacesInfo

# Save Interface Infromation 
ifconfig -a >$IFINFO

# Get the list of dataplane interfaces 
ifconfig -a | grep "Link encap" | grep -v ^lo | grep -v ^br | awk '{print $1, $5}' > $IFTMPFILE

CONTROLMAC=`/usr/bin/geni-get control_mac`
CONTROLNAME=""

# Remove the control interface from the list
while read if; do
    IFNAME=`echo $if | awk '{print $1}'` 
    IFMAC=`echo $if | awk '{print $2}' | sed -e 's/://g'`
    if [ "$IFMAC" == "$CONTROLMAC" ]; then
        CONTROLNAME=$IFNAME
    else
        IFLIST="$IFLIST $IFNAME"
    fi
done < $IFTMPFILE

# If there is no control interface, problem so exit.
if [ "$CONTROLNAME" == "" ]; then
    echo "Control interface with MAC $CONTROLMAC not found"
    rm -f $IFTMPFILE
    exit 
fi

# Create the switch if it doesn't already exist
sudo ovs-vsctl list-br | grep -q $SWITCHNAME 
if [ $? -ne 0 ]; then
    sudo ovs-vsctl add-br $SWITCHNAME
fi

# Add ports to bridge for each of the interfaces and clear IP addresses
for i in $IFLIST; do
    sudo ovs-vsctl list-ports $SWITCHNAME | grep -q ${i}
    if [ $? -ne 0 ]; then
        sudo ovs-vsctl add-port $SWITCHNAME ${i}
    fi
    sudo ifconfig ${i} 0.0.0.0
done

#rm -f $IFTMPFILE
