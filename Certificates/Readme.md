Certificates for Cert-Chain and auth

Create the CA Key and Certificate
========================================

Generate a private key with the correct length
`openssl genrsa -aes256 -out ca-private-key.pem 3072`
	=> Password e.g. "dummy_challenge"

Generate corresponding public key
`openssl rsa -in ca-private-key.pem -pubout -out ca-public-key.pem`

Generate the CA certificate
`openssl req -new -x509 -key ca-private-key.pem -out ca.crt -days 360 -subj "/CN=CA-Master" -addext 'extendedKeyUsage=serverAuth,clientAuth'`


Create the Node Certificate suitable for server authentication
========================================

Create the client private key
`openssl genrsa -aes256 -out client1-private-key.pem 3072`
	=> Password (not the CA password) e.g. "dummy_client"

Create the signing request
`openssl req -new -sha256 -key client1-private-key.pem -out client1.csr -subj "/CN=Hostname"`

```
nano / notepad.exe client.cnf
	extendedKeyUsage = serverAuth, clientAuth
```

Creare the crt
`openssl x509 -req -in client1.csr -CA ca.crt -CAkey ca-private-key.pem -CAcreateserial -days 1000 -sha256 -extfile client.cnf -out client1.crt`

Combine private key and certificate to pfx file
`openssl pkcs12 -export -inkey client1-private-key.pem -in client1.crt -out client1.pfx`
	=> Add export password: dummy_export (used for import o_0)
