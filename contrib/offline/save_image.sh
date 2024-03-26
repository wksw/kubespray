#!/bin/bash

ROOTDIR=$(cd $(dirname $0);pwd)

OUTPUT_DIR="$ROOTDIR/offline-images"

rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

PROCESS=${1:-10}

trap "exec 3>&-;exec 3<&-;exit 0" 2
[ -e ./$$ ] || mkfifo ./$$
exec 3<> ./$$
rm -rf ./$$
for i in $(seq $PROCESS)
do
	echo >&3
done

while read image
do
	read -u3
	{
		image_name="$(echo ${image//./_}|sed 's#/#_#g' |sed 's#:#_#g')"
		echo "download $image_name"
		docker pull $image
		docker save -o $OUTPUT_DIR/$image_name $image
		docker rmi $image
		echo >&3
	}&
done < temp/images.list
wait
echo 3>&-
echo 3<&-
