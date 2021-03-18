#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "pass the exercise number. Example : ./setup 1"
fi
./init.sh

echo "Creating cert for Root CA1"
rm rootca1.key || true
rm rootca1.req || true
rm rootca1.pem || true

openssl req -new -keyout rootca1.key -out rootca1.req -nodes -config rootca1.cnf
openssl ca -out rootca1.pem -keyfile rootca1.key -selfsign -config rootca1.cnf -in rootca1.req  -batch -notext
cat rootca1.key >> rootca1.pem

echo "Root CA1 was created with config rootca1.cnf. Play around the config and analyze the certificate"
 if [ "$1" -eq "1" ]
 then
   echo "setup for exercise 1 is complete"
   exit
fi

echo "Generate CSR for Intermediate CA"
openssl req -new -keyout intermediateca.key -out intermediateca.req -nodes -config intermediateCA.cnf

echo "Sign Intermediate CA using Root CA 1"
openssl ca -in intermediateca.req -cert rootca1.pem -keyfile rootca1.key -out intermediateca.pem -config rootca1.cnf -batch -notext
cat intermediateca.key >> intermediateca.pem

echo "Generate CSR for localhost"
openssl req -new -keyout localhost.key -out localhost.req -nodes -config localhost.cnf
openssl ca -in localhost.req  -cert intermediateca.pem -keyfile intermediateca.key -out localhost.pem -config intermediateca.cnf  -batch -notext
cat localhost.key >> localhost.pem

#echo "Verify localhost pem file"
#openssl verify -CAfile rootca1.pem -untrusted intermediateca.pem localhost.pem


#openssl s_client -connect  dedicated-shard-00-00.vxe9y.mongodb-dev.net:27017  < /dev/null  2>/dev/null  | openssl x509  -text > mongo.cert

 if [ "$1" -eq "2" ]
 then
   echo "setup for exercise 2 is complete"
   exit
fi

echo "Revoke and verify certificate"
openssl ca -revoke localhost.pem  -config intermediateCA.cnf
openssl verify -CAfile rootca1.pem -untrusted intermediateca.pem localhost.pem

openssl ca -revoke mongo.cert  -config intermediateCA.cnf

openssl ca -gencrl -out intermediateca.crl  -config intermediateCA.cnf
openssl crl -in intermediateca.crl  -text -noout
