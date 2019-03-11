#!/bin/bash
yum update -y
yum upgrade -y
amazon-linux-extras install epel -y
yum install ansible -y