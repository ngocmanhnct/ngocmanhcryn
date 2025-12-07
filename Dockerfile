# 1. Build Stage
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
# Tải thư viện về trước để cache (giúp build nhanh hơn)
RUN mvn dependency:go-offline

COPY src ./src
# Build ra file WAR
RUN mvn clean package -DskipTests

# 2. Run Stage (Tomcat 10 cho Jakarta hoặc Tomcat 9 cho Javax)
# Vì bạn dùng javax.servlet (Tomcat 9) hoặc jakarta (Tomcat 10)
# Dưới đây là cấu hình cho Tomcat 10 (nếu dùng thư viện jakarta trong pom.xml)
FROM tomcat:10.1-jdk17

# Xóa các app mặc định của Tomcat cho nhẹ
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file WAR vừa build vào thư mục webapps của Tomcat
# Lưu ý: target/EmailList-1.0-SNAPSHOT.war là tên mặc định, có thể khác tùy pom.xml
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]