---
title: "Application Insights and Log Analytics in Asp Net Using Serilog" # Title of the blog post.
date: 2021-06-21 # Date of post creation.
draft: true # Sets whether to render this page. Draft of true will not be rendered.
toc: false # Controls if a table of contents should be generated for first-level links automatically.
images:
  - src: "2021/06/21/application-insights-and-log-analytics-in-asp-net-using-serilog/images/Header.png"
    alt: ""
    stretch: ""
tags: ['web app', 'app insights', 'log analytics', 'serilog']
categories: ['azure']
---

[Few months ago](2021/02/28/build-yourself-a-web-app-in-azure) I started working on setting up the infrastructure in Azure for the Web Application. In real life the app is more advanced, this series is a wrap up of my thoughts and learnings.

After preparing the initial idea about the pieces I wanted to put together this post is about starting - preparing a basic web application written in C# using .NET 5.0, and deployed to App Service. Also - once I have the application I want to store logs and telemetry in Azure using Application Insights and Log Analytic Workspaces. Also I will use [Serilog](https://serilog.net) to see and send the logs to Azure.

Althoug the developers work mostly using Visual Studio my main environment is VS Code + Az CLI ( and/or PowerShell Az module).

## The web application

I will use a default template for the MVC app. Then I will add one button, that will help me to test if my logging works as expected. To build the app I open my default PowerShell 7.1 environment, go to a directory, create the skeleton of my app and run it to see if everything works as expected.

```powershell
cd d:\_websites
dotnet new mvc -o videowebapp
dotnet run
```

The app starts listening on ports 5000 and 5001

```cmd
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:5001
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5000        
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
info: Microsoft.Hosting.Lifetime[0]
      Content root path: D:\_websites\videowebapp
```

I will add the code to the git repository on GitHub. Run the commands in the `videoapp` folder

```powershell
# initialise local repository
git init
# default .gitignor for dotnet apps
dotnet new gitignore
# add all files
git add *
# commit the changes
git commit -m "initial version"
# create a project in GitHub using GitHub CLI
gh auth login --hostname github.com --web
gh repo create BartekR/dotnet-app-monitoring-azure
# notice the prompt: This will add an "origin" git remote to your local repository. Continue? Yes
# push the changes to GitHub
git push --set-upstream origin master
```

The code I use comes from the Microsoft Learn tutorial [Instrument server-side web application code with Application Insights](https://docs.microsoft.com/en-gb/learn/modules/instrument-web-app-code-with-application-insights/) with slight modifications. After creating the project I add the button to the `Views/Home/Index.cshtml` page.

```csharp
<div>
    @using (Html.BeginForm("Like", "Home"))
    {
        <input type="submit" value="Like" />
        <div>@ViewBag.Message</div>
    }  
</div>
```

and the action for the button in `Controllers/HomeController.aspx`

```csharp
[HttpPost]
public ActionResult Like(string button)
{
    ViewBag.Message = "Thank you for your response";
    return View("Index");
}
```

It works.

![Button works](./images/ButtonWorks.png#center)

Dalej

1. Przykład domyślnego logowania za pomocą ILoggera
2. Utworzenie webapp (free) + application insights + log analytics
3. Integracja z Application Insights out-of-the-box + weryfikacja jak to wygląda
4. Dodanie Seriloga + Serilog.Extensions.Configuration + Serilog.AspNetCore + Serilog.Sinks.ApplicationInstights i porównanie logów w Application Insights
5. Dodanie sinków: Serilog.Sinks.Seq i analiza co przychodzi w requestach
6. Użycie UseSerilogRequestLoging() + porównanie
7. WithLogContext enricher (?)
8. Dodanie Serilog.Sinks.LogAnalytics z domyślną konfiguracją + pokazanie jak wygląda log
9. Użycie Overrides, żeby nie pokazywać śmieci
10. Log Analytics + flatten
11. Dodanie Serilog.Enrichers.CorrelationId

Now - to get the out-of-the-box Application Insights integration it's enough to add the `Microsoft.ApplicationInsights.AspNetCore` module to the project running (in the `videowebapp` project folder):

```powershell
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```