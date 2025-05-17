FROM node:20.11.1
RUN apt-get update && apt-get install -y \
    && groupadd testgroup && useradd -m -g testgroup testuser
WORKDIR /my-app
COPY . .
RUN chown -R testuser:testgroup /my-app \
    && chmod -R 755 /my-app 
USER testuser
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]