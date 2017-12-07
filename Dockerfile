FROM microsoft/terraform-test:0.10.8

RUN mkdir /usr/src/terraform-azure-compute
COPY . /usr/src/terraform-azure-compute

WORKDIR /usr/src/terraform-azure-compute
RUN ["bundle", "install", "--gemfile", "./Gemfile"]
