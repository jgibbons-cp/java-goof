## Java Goof

Forked from [Snyk](https://github.com/snyk/java-goof)  

A vulnerable demo application, initially based on [Ben Hassine](https://github.com/benas/)'s [TodoMVC](https://github.com/benas/todolist-mvc).

The goal of this application is to demonstrate through example how to find, exploit and fix vulnerable Maven packages.

This repo is still incomplete, a work in progress to support related presentations.

Datadog Demo Purpose
--

* NOTE - ONLY tested on Amazon Linux 2 AMI (HVM), SSD Volume Type, T2 medium
* In env_vars.sh set DATADOG_APP_KEY, DATADOG_API_KEY and SNYK_TOKEN
[snyk](https://support.snyk.io/hc/en-us/articles/360003812538-Install-the-Snyk-CLI) -
you will need an API key
* To configure the vm and start the webapp run `sh setup.sh` from the root directory
* Once the webapp is up, you can access is at FQDN:8080 (8080 will need to be
open for external access) and login with foo@bar.org / foobar
* You can then go to the Datadog app and look at the
[traces](https://app.datadoghq.com/apm/traces) coming in and the
[profiles](https://app.datadoghq.com/profiling) (after a few minutes).  In the
profiles, at first, you will see "None Detected" under the "Vulnerability
Severity" column.  
* Now we are set to exploit the application.  
* In a shell, execute `export DOMAIN_NAME=<domain_name>` where
<domain_name> is either localhost or the FQDN of the host (8080 will need to be
open for external access)
* The first exploit - change permission on a root Java binary.  The reference
used for this is the following [webinar](https://www.youtube.com/watch?v=oEFAQZXYpfQ)
 hosted by Snyk and Datadog.  This uses a vulnerability in struts that allows
 shell commands on the host that is running the webapp.  In the repo root,
 execute `vi exploits/struts-exploit-headers.txt`  This is a multipart/form-data
 header that struts understands and allows the execution of a shell command.  Next,
 `vi exploits/struts-exploit.sh` and let's take a look at the shell code.  It uses
 sed to replace COMMAND with chown to change the permissions of the native2ascii
 binary in the JVM.  This is the method of exploit that was used in the Experian attack.  
 Execute it with `cd exploits && sh struts-exploit.sh`  Run it a few times to
 ensure it is not sampled out and then you can stop here if you want.  When you see
 a profile with "Critical" in the "Vulnerability Severity" column click in then
 go to "Analysis" and you can see the struts expoit.
 * Next we will exploit the app from UI using the zip-slip vulnerability.  The
 reference I used is from
 [a Snyk research post](https://snyk.io/research/zip-slip-vulnerability) and a
 webinar included on the [page](https://www.youtube.com/watch?v=l1MT5lr4p9o).  
 This uses Java code that does not check directory structure when unpacking a
 zip file.  It takes the user up 20 levels of ../ (if you hit root you will
   keep traversing back to root) then we traverse to the JVM directory to
   overwrite the native2ascii binary with our own binary and executable code.  In
   the application go to `FQDN:8080/todo/new` and create a few todos.  Then
   click the link for 'Upload Files' and upload zip-slip-datadog_example.zip  
   Now click 'My Files' and you will see `root_of_repo/public` and one file
   good.txt.  The new native2ascii binary will overwrite the Java binary by
   traversing the host directory structure outside of the upload (public) directory.  
   Now add another todo and you will see Gotcha! instead of your todo as we have
   executed code using our binary in the the webapp.  The code that is exploited
   is in todolist-core/src/main/java/io/github/todolist/core/domain/Todo.java  
   `import static io.github.todolist.core.Statics.NATIVE2ASCII;` sets the JDK
   location if `$JAVA_HOME` is unset.  We set it in env_vars.sh  The method that is
   exploited is `public Todo(...)`  Add three of four todos to ensure sampling does
   not exclude the run in a profile and in a few minutes you should see Critical
   in the "Vulnerability Severity" column.  Click into the profile and then go
   into Analysis and you will see a hibernate vulnerability.
  * Enjoy!


Original README below ... left as was...
--

## Build and run Todolist MVC

(from the original README)

*Note that to run locally, you need JDK 8.*

1.  Check out the project source code from github : `git clone https://github.com/snyk/java-goof.git`
2.  Open a terminal and run the following command from root directory : `mvn install`
3.  Choose a web framework to test and run it. For example : `cd todolist-web-struts && mvn tomcat7:run` (note: this example currently only copied the Struts demo)
4.  Browse the following URL : `localhost:8080/`
5.  You can register a new account or login using the following credentials : foo@bar.org / foobar

## Running with docker-compose
```bash
docker-compose up --build
docker-compose down
```

## Deploy Application on Heroku

- [Heroku instructions](DEPLOY_HEROKU.md)

## License
This repo is available released under the [MIT License](http://opensource.org/licenses/mit-license.php/).
# java-goof
