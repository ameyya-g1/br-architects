FROM  tomcat:8.0-alpine

LABEL author="ameya"
LABEL email="ameyya.g1@gmail.com"

RUN apk update
RUN apk add git
RUN apk add maven

RUN mkdir /home/sample-web
RUN mkdir /home/sample-web/git_code

WORKDIR /home/sample-web/git_code

RUN rm -rf J2eeApp
RUN git clone https://github.com/ameyya-g1/br-architects.git

WORKDIR /home/sample-web/git_code/J2eeApp/sample-web

RUN git checkout master

RUN mvn clean install

RUN cp /home/sample-web/git_code/J2eeApp/sample-web/target/sample-web.war  /usr/local/tomcat/webapps/
RUN rm -rf /usr/share/tomcat/webapps/sample-web

EXPOSE 8080
CMD ["catalina.sh", "run"]
