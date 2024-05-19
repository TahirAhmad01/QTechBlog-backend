# README

### Project Setup
- Clone the project:

        git clone git@github.com:TahirAhmad01/TechTonicBlog-backend.git
        cd TechTonicBlog-backend
        cp .env.sample .env

- Install dependencies:

        bundle install
        yarn install
        rake db:create
        rake db:migrate
        rake db:seed

- Run the Rails server:

        rails s