Adress for web-server, database endpoint and API url can be found in outputs section which apperas after executing `terraform apply`. Example:
```
Outputs:

api_url = "https://hl6tmgbc88.execute-api.us-west-2.amazonaws.com/dev"
database_endpoint = "terratest-example.cczdtbqcu3qr.us-west-2.rds.amazonaws.com:5432"
web_server_public_ip = "54.218.138.42"
```

Web server is running of port 8080 by default.

API can be used by executing:
```
curl <api_url>/roman-numeral/<number>
```
For example api_url = "https://hl6tmgbc88.execute-api.us-west-2.amazonaws.com/dev". \
Then API can be used as:
```
curl https://hl6tmgbc88.execute-api.us-west-2.amazonaws.com/dev/roman-numeral/2020
```
