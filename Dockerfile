# Dockerfile copiato da ror-rails-goldie copialo da la..
# Note rubyver must match the one in Gemfile..
FROM ruby:2.7.2

# Added for YARN or it wont work...
# https://medium.com/@yuliaoletskaya/how-to-start-your-rails-app-in-a-docker-container-9f9ce29ff6d6

# Dal 1.0.6 voglio anche libvips che se no ciocca.
#RUN sudo apt-get clean
RUN apt-get update
RUN apt-get install -y \
  curl \
  build-essential \
  libvips \
  libmariadb-dev \
  libpq-dev 
#  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
#  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
#  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
#  apt-get update && apt-get install -y nodejs yarn

ENV APP_HOME /riccardo-rails-app

# We specify everything will happen within the /app folder inside the container
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

#########################################################################
# 1. We copy these files from our current application to the /app container
COPY Gemfile Gemfile.lock ./
# We install all the dependencies
RUN bundle install

# 2022-02-06 with rails 7, Seems like the days of manual yarn are over! woohoo!
#COPY package.json .
#COPY yarn.lock .

#### CACHE ENDS HERE :)

# We copy all the files from our current application to the /app container
COPY . .

# TODO maybe we can do this BEFORE copy? I'm ignorant on YARN...
#RUN yarn install --check-files

ENV RAILS_ENV production

# We expose the port
EXPOSE 8080
# Start the main process: $ rails server -b 0.0.0.0
#CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]
CMD ["/riccardo-rails-app/entrypoint-8080.sh"]
