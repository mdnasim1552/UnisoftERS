<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@ViewBag.Title - My ASP.NET Application</title>
    @Styles.Render("~/Content/css")
</head>
<body>
    <div class="navbar navbar-inverse navbar-fixed-top">
        <div class="container">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                @Html.ActionLink("SE", "Index", "Claim", New With {.area = ""}, New With {.class = "navbar-brand"})

            </div>
            <div Class="navbar-collapse collapse">
                <ul Class="nav navbar-nav">

                    @code
                        If (Request.IsAuthenticated = True) Then
                    End code
                    <li class="navbar-text">
                        Hello @Session("FullName")
                    </li>
                    <li>
                        @Html.ActionLink("Sign Out", "SignOut", "SSOAccount")
                    </li>

                    @code
                        Else
                    End code
                    <li>
                        @Html.ActionLink("Sign In", "SignIn", "SSOAccount")

                    </li>

                    @code
                        End If


                    End Code
                </ul>
            </div>
        </div>
    </div>

    <div Class="container body-content">
        @RenderBody()
        <hr />
        <footer>
            <p>
                Copyright © 2018 - @DateTime.Now.Year HD Clinical Ltd
                <br>
                <a href="www.hd-clinical.com">www.hd-clinical.com </a>
            </p>
        </footer>
    </div>

    @Scripts.Render("~/bundles/jquery")
    @Scripts.Render("~/bundles/bootstrap")
    @RenderSection("scripts", required:=False)
</body>
</html>
