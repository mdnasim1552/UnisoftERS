<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="SchedulerTransformation.aspx.vb" Inherits="UnisoftERS.SchedulerTransformation1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:TextBox ID="txtDiaryId" runat="server" />&nbsp;<asp:Button ID="btnTransformDiary" runat="server" Text="Transform Diary" OnClick="btnTransformDiary_Click" />
            <asp:Button ID="btnTransformAll" runat="server" Text="Transform All Diaries" OnClick="btnTransformAll_Click" />
            <asp:Label ID="lblCompleteStatus" runat="server" />
        </div>
    </form>
</body>
</html>
