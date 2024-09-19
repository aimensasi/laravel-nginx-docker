## How to Use

1. Clone the repository:
   
    git clone https://github.com/yourusername/your-repo-name.git
   

2. Copy files into your project:

    a. Place the `Dockerfile` and `.dockerignore` files inside the root directory
    b. Create a `docker` directory and add the rest of the files into it

3. Install NPM Dependencies:
    The Dockerfile uses Bun to install dependencies for faster builds.
    Change your package.json to use Bun by running:
   
    ```
        bun install
    ```
   
    This will generate the `bun.lock` file

4. Build the Docker image:
   
    ```
        docker build -t your-image-name .
    ```
   

5. Use Docker Compose to run the application:
    The `docker-compose.yml` file will help generate the necessary services and allow you to pass your environment variables.
   
    ```
        docker compose up -d
    ```

    This will start your application in detached mode. You can now verify that it's running as expected.

