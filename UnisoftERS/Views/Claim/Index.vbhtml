@Code
    ViewData("Title") = "Index"
End Code



@Code
    ViewBag.Title = "Index"
End  Code


<h2>Index</h2>
<html>
<head>
    <meta name="viewport" content="width=device-width" />
    <title>Sign-In With  Azure AD</title>
    <link href="@Url.Content("~/Content/bootstrap.min.css")" rel="stylesheet" type="text/css" />
</head>
<body style="padding:50px">
    <h3>Main Claims:</h3>
    @code
        If Request.IsAuthenticated = True Then
    End code
    <Table Class="table table-striped table-bordered table-hover">
        <tr> <td> Name</td><td>@ViewBag.Name</td></tr>
        <tr><td>Username</td><td>@ViewBag.Username</td></tr>
        <tr><td>Subject</td><td>@ViewBag.Subject</td></tr>
        <tr><td>TenantId</td><td>@ViewBag.TenantId</td></tr>
    </Table>
    <br />
    <h3>All Claims:</h3>
    <table class="table table-striped table-bordered table-hover table-condensed">
        @code
            For Each claim In System.Security.Claims.ClaimsPrincipal.Current.Claims
        End code
        <tr><td>@claim.Type</td><td>@claim.Value</td></tr>
        @code
            Next
        end code
    </table>
    @code
        Else
        @Html.ActionLink("SignIn", "SignIn", "SSOAccount", Nothing, New With {Key .[class] = "btn btn-primary"})
        End If
    End Code
    @*<Table Class="table table-striped table-bordered table-hover">
            <tr> <td> Name</td><td>@ViewBag.Name</td></tr>
            <tr><td>Username</td><td>@ViewBag.Username</td></tr>
            <tr><td>Subject</td><td>@ViewBag.Subject</td></tr>
            <tr><td>TenantId</td><td>@ViewBag.TenantId</td></tr>
        </Table>
        <br />
        <h3>All Claims:</h3>
        <table class="table table-striped table-bordered table-hover table-condensed">
            @code
                For Each claim In System.Security.Claims.ClaimsPrincipal.Current.Claims
            End code
            <tr><td>@claim.Type</td><td>@claim.Value</td></tr>
            @code
            Next
            end code
        </table>
        <br />
        <br />
        @Html.ActionLink("Sign out", "SignOut", "Home", Nothing, New With {Key .[class] = "btn btn-primary"})*@
</body>
</html>
<h2>IDP Mode: @ViewBag.SSOIDPMode</h2>



