provider "aws"{
    access_key = "from .csv file"
    secret_key = "from .csv file"
    region = "ap-south-1"
}

provider "aws"{
    region = "ap-south-1"
    alias  = "central" 
    access_key = "from .csv file"
    secret_key = "from .csv file"  
}
