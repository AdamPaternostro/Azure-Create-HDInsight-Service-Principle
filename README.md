# Azure-Create-HDInsight-Service-Principle
Creates a certificate for HDInsights for authenticating against Azure Data Lake.  
This will
- Create the Azure Application (aka a Service Principle. In this case a Service Principle backed by a certificate versus a key (password))
- Generate a PFX
- Display the JSON that is needed for an ARM template (the certificate will also be Base64 encoded)
