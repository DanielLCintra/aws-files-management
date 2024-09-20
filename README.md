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

### Atualize o arquivo src/index.css:
```
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  font-family: 'Arial', sans-serif;
  background-color: #f7f7f7;
  margin: 0;
  padding: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}

.container {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.header img {
  width: 40px;
  height: auto;
  margin-right: 10px;
}

.upload-button {
  background-color: #0073e6;
  color: white;
  padding: 10px 15px;
  border-radius: 5px;
  border: none;
  cursor: pointer;
  transition: background-color 0.3s;
  width: 100%;
}

.upload-button:hover {
  background-color: #005bb5;
}

.file-list {
  margin-top: 20px;
  padding: 0;
}

```

### Atualize o arquivo src/App.js
```
import React, { useState, useEffect } from 'react';
import './index.css';

const Loader = () => {
  return (
    <div role="status" className="flex items-center justify-center">
      <svg
        aria-hidden="true"
        className="w-8 h-8 text-gray-200 animate-spin dark:text-gray-600 fill-blue-600"
        viewBox="0 0 100 101"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
          fill="currentColor"
        />
        <path
          d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
          fill="currentFill"
        />
      </svg>
      <span className="sr-only">Loading...</span>
    </div>
  );
};


function App() {
  const [files, setFiles] = useState([]);
  const [selectedFile, setSelectedFile] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const handleFileChange = (e) => {
    setSelectedFile(e.target.files[0]);
  };

  const handleUpload = async () => {
    setIsLoading(true);
    if (!selectedFile) return;

    const reader = new FileReader();
    reader.onloadend = async () => {
      const base64data = reader.result.split(',')[1];

      try {
        await fetch(`${process.env.REACT_APP_API_URL}/upload?fileName=${selectedFile.name}`, {
          method: 'POST',
          headers: {
            "Content-Type": "text/plain"
          },
          body: base64data,
        });
        fetchFiles();
        setIsLoading(false);
      } catch (error) {
        setIsLoading(false);
        console.error('Error uploading file:', error);
      }
    };

    reader.readAsDataURL(selectedFile);
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
    <div className="container">
      <div className="header">
        <img src={"https://w7.pngwing.com/pngs/862/624/png-transparent-aws-vector-brand-logos-icon-thumbnail.png"} alt="AWS Logo" />
        <h1 className="text-2xl font-bold">Gestão de Arquivos</h1>
      </div>

      <label class="block mb-2 text-sm font-medium text-gray-900 dark:text-white" for="file_input">Upload file</label>
      <input class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400" aria-describedby="file_input_help" id="file_input" type="file" onChange={handleFileChange} />
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-300 mb-5" id="file_input_help">SVG, PNG, JPG or GIF (MAX. 800x400px).</p>

      <button
        onClick={handleUpload}
        className="upload-button"
      >
        {isLoading ? (<Loader />) : ("Upload")}
      </button>


      <h2 class="mb-2 text-lg font-semibold text-gray-900 dark:text-gray-600 m-5 ">Arquivos Enviados</h2>
      <ul class="max-w-md space-y-1 text-gray-500 list-disc list-inside dark:text-gray-400">
        {files.map((file, index) => (
          <li key={index}>
            <a
              href={`${process.env.REACT_APP_BUCKET_URL}/${file}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-500 hover:underline"
            >
              {file}
            </a>
          </li>
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
aws s3 sync build/ s3://meu-frontend-bucket-daniel-19092024
```

### Para destruir todos os objetos criados com terraform
```
terraform destroy -auto-approve
```