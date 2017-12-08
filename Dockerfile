FROM microsoft/terraform-test:0.11.1

RUN mkdir /usr/src/terraform-azure-compute
COPY . /usr/src/terraform-azure-compute

WORKDIR /usr/src/terraform-azure-compute
RUN ["bundle", "install", "--gemfile", "./Gemfile"]
