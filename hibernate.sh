#!/bin/bash

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/.$//')

eval $(aws --output text sts assume-role --role-arn arn:aws:iam::846880483810:role/data-ops-windows-instance-hibernator --role-session-name data-ops-windows-instance-hibernator | tail -n 1 | awk '{ print " export AWS_ACCESS_KEY_ID="$2"\n export AWS_SECRET_ACCESS_KEY="$4"\n export AWS_SESSION_TOKEN="$5"\n" }') >&2

exitValue=0
for name in $@ ; do
	instances=$(aws --output text ec2 describe-instances --query "Reservations[].Instances[?Platform=='windows'&&State.Name=='running'&&Tags[?Key=='Name'].Value | [0]=='"$name"'][].[InstanceId,PrivateIpAddress]") >&2
	if echo $instances | grep -q . ; then
		id=$(echo $instances | cut -f1 -d\ )
		ip=$(echo $instances | cut -f2 -d\ )
		echo -n "$name: Sending shutdown command to instance $id on IP $ip... "
		ssh -i ./windows-ssh-key Administrator@$ip "cmd /c start /B shutdown /h & cmd /c exit" >&2
		if ! aws ec2 wait instance-stopped --instance-ids $id >&2 ; then
			echo "SHUTDOWN FAILED"
			exitValue=255
		else
			echo "SHUTDOWN COMPLETE"
		fi
	fi
done

exit $exitValue
