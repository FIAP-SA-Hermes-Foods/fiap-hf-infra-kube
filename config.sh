#!/bin/bash

sed -i s:{{vpc-cidr}}:$vpc_cidr:g ./eks-terraform.tf;

sed -i s:{{public-subnet-1}}:$public_subnet_1:g ./eks-terraform.tf;
sed -i s:{{public-subnet-2}}:$public_subnet_2:g ./eks-terraform.tf;

sed -i s:{{private-subnet-1}}:$private_subnet_1:g ./eks-terraform.tf;
sed -i s:{{private-subnet-2}}:$private_subnet_2:g ./eks-terraform.tf;




