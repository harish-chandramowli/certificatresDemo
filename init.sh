rm index || true
touch index
if [[ ! -f "serial.txt" ]]; then
    echo "Create serial.txt"
    touch serial.txt
    echo 01 > serial.txt
fi

rm intermediatecaindex || true
rm intermediatecaserial.txt || true
rm intermediatecacrl || true
touch intermediatecaindex
touch intermediatecaserial.txt
echo 00 > intermediatecaserial.txt
touch intermediatecacrl
echo 00 > intermediatecacrl
