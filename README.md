# Criando um Sistema Completo de Upload e Visualização de Arquivos com AWS Lambda, S3, SNS, API Gateway,React + Tailwind CSS e Terraform!

### Instalação do terraform
```
sudo apt-get update && sudo apt-get install -y terraform
```

### Verifique se o terraform foi instalado corretamente.
```
terraform -v
```

### Instale o aws cli

### Rode o comando de configuração para vincular seu computador com a sua conta aws
```
aws configure
```

### Para criar a pasta do projeto:

```
mkdir aws-files-management
cd aws-files-management
```

### Para criar as subpastas do projeto

```
mkdir frontend backend infra
```

### Acesse a pasta da lambda e rode os comandos
```
cd backend/upload
npm init
npm i -S aws-sdk
echo BUCKET_NAME=<your-bucket-name> >> .env.EXAMPLE
echo BUCKET_NAME=meu-upload-bucket >> .env
```
e
```
cd backend/list
npm init
npm i -S aws-sdk
echo BUCKET_NAME=<your-bucket-name> >> .env.EXAMPLE
echo BUCKET_NAME=meu-upload-bucket >> .env
```

### Para fazer o zip dos arquivos da lambda

```
cd backend/list
zip -r lambda_list.zip list.js node_modules

```

e

```
cd backend/upload
zip -r lambda_upload.zip index.js node_modules

```

### Para criar o frontend
obs: acesse o diretório raiz do projeto
```
npx create-react-app frontend
cd frontend
npm install tailwindcss postcss autoprefixer
npx tailwindcss init -p

```

### Atualize o arquivo tailwind.config.js
```
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
}

```

### Atualize o arquivo src/index.css com o Tailwind CSS:
```
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Rode o projeto para certificar que está funcionando
```
npm run start
```

### Faça o build da aplicação frontend:
```
npm run build
```
### Crie os arquivos de infra

### Rode os comandos do terrafrom

#### Inicializar o projeto
```
terraform init
```
#### Executar o planejamento
```
terraform plan
```

#### Executar o planejamento
```
terraform apply
```

### Suba a aplicação para o bucket s3
```
aws s3 sync build/ s3://meu-frontend-bucket
```