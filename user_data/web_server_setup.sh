#!/bin/bash
yum update -y
yum install -y httpd

systemctl start httpd
systemctl enable httpd

echo "<h1>Here's a warm welcome from Love Uzowulu to you 😊</h1><p>Thanks for stopping by!</p><p><strong>Served by:</strong> $(hostname -f)</p>" > /var/www/html/index.html