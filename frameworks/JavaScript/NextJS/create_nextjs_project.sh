# Create a new directory for your project
mkdir $1
cd $1

# Initialize a new npm project
npm init -y

# Install Next.js and React
npm install next react react-dom

# Create the necessary files and directories
mkdir pages public styles

# Create a simple homepage
echo "export default function Home() { return <div>Welcome to Next.js!</div> }" > pages/index.js

# Add scripts to package.json
npm pkg set scripts.dev="next dev"
npm pkg set scripts.build="next build"
npm pkg set scripts.start="next start"
npm pkg set scripts.lint="next lint"

# Run the development server
npm run dev