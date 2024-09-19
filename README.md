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
zip -r lambda_list.zip .env index.mjs node_modules

```

e

```
cd backend/upload
zip -r lambda_upload.zip .env index.mjs node_modules

```

### Para criar o frontend
obs: acesse o diretório raiz do projeto
```
npx create-react-app frontend
cd frontend
npm install tailwindcss postcss autoprefixer -S
npx tailwindcss init -p
rm -rf .git .gitignore

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

### Atualize o arquivo src/App.js
```
import React, { useState, useEffect } from 'react';
import './index.css'

function App() {
  const [files, setFiles] = useState([]);
  const [selectedFile, setSelectedFile] = useState(null);

  const handleFileChange = (e) => {
    setSelectedFile(e.target.files[0]);
  };

  const handleUpload = async () => {
    if (!selectedFile) return;
    const formData = new FormData();
    formData.append('file', selectedFile);

    try {
      await fetch(`${process.env.REACT_APP_API_URL}/upload?fileName=${selectedFile.name}`, {
        method: 'POST',
        body: selectedFile,
      });
      fetchFiles();
    } catch (error) {
      console.error('Error uploading file:', error);
    }
  };

  const fetchFiles = async () => {
    try {
      const response = await fetch(`${process.env.REACT_APP_API_URL}/list-files`);
      const files = await response.json();
      setFiles(files);
    } catch (error) {
      console.error('Error fetching files:', error);
    }
  };

  useEffect(() => {
    fetchFiles();
  }, []);

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold">Upload de Arquivos</h1>
      <input
        type="file"
        onChange={handleFileChange}
        className="my-4"
      />
      <button
        onClick={handleUpload}
        className="bg-blue-500 text-white px-4 py-2 rounded"
      >
        Upload
      </button>

      <h2 className="text-xl mt-6">Arquivos Enviados</h2>
      <ul className="list-disc pl-5">
        {files.map((file, index) => (
          <li key={index}>{file}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;


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
terraform apply -auto-approve
```

### Suba a aplicação para o bucket s3
```
aws s3 sync build/ s3://meu-frontend-bucket
```

### Para destruir todos os objetos criados com terraform
```
terraform destroy -auto-approve
```