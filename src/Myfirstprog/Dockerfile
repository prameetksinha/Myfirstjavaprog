# Use a base image with the Java Runtime Environment (JRE)
FROM openjdk:11

# Set the working directory inside the container
WORKDIR /app

# Copy the compiled Java class to the container
#COPY Myfirstjavaprogram.class .

# Command to run the Java program
COPY javabuild.sh javabuild.sh
CMD ./javabuild.sh