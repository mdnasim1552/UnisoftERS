<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Blank.aspx.vb" Inherits="UnisoftERS.Blank" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%=Request.QueryString("title")%></title>
    <style type="text/css">
        h4{
            border-bottom-style:solid;
            border-bottom-color:lightgray;
            border-bottom-width:1px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h4>Report in works</h4>
        <p>The report you are looking for in under preparation.</p>
        <p>Please, come back soon!!!</p>
        <table>
            <tr>
                <td>ProcType</td>
                <td><%=Request.QueryString("ProcType")%></td>
            </tr>
            <tr>
                <td>columnName</td>
                <td><%=Request.QueryString("columnName")%></td>
            </tr>
            <tr>
                <td>rowID</td>
                <td><%=Request.QueryString("rowID")%></td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
