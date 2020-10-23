### VolumeIDを出力

```
aws ec2 describe-instances --output=text --filter "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[][].{InstanceId: InstanceId, VolumeId: join(`, `, BlockDeviceMappings[].Ebs[].VolumeId)}'
```

### VolumeIDからサイズを出力

```
volumes=(
vol-xxxxxxxx
vol-xxxxxxxx
)
for volume in $volumes; 
do
	aws ec2 describe-volumes --volume-id $volume --query 'Volumes[].{VolumeId:VolumeId,InstanceId:Attachments[].InstanceId|[0], Name:Tags[?Key==`Name`].Value|[0], Size:Size}' --output text
done
```
