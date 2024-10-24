<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="PopUp.aspx.vb" Inherits="UnisoftERS.PopUp" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%=WindowTitle%></title>
    <style type="text/css">
        #GridView1{
            width:100%;
            height:100%;
        }
        td{
            border-style:solid;
            border-width:1px;
            border-color:lightgray;
        }
        .rgMasterTable {
            margin-top:10px;
        }
        h4{
            border-bottom-style:solid;
            border-bottom-color:lightgray;
            border-bottom-width:1px;
        }
        #RadGrid1{
            border:none;
        }
        table.rgMasterTable{
            border-style:solid;
            border-color:lightgray;
            border-width:1px;
        }
        .CaseNoteNo{
            min-width:75px;
            text-align:center;
        }
        .PatientName{
            min-width:150px;
            text-align:center;
        }
        .CreatedOn{
            min-width:65px;
            text-align:center;
        }
        .ProType{
            min-width:65px;
            text-align:center;
        }
    </style>
    <script src="../../Scripts/jquery-1.10.2.js"></script>
</head>
<body >
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="form1" />
        <div style="min-width:500px;">
<%--            <h4>Works in progress!!!</h4>--%>
            <h4>Analysis for <%=GetValue("SELECT Consultant FROM v_rep_JAG_Consultants A, ERS_ReportConsultants B WHERE A.ReportID = B.ConsultantID And B.UserID=" + Session("PKUserID").ToString + " And B.AnonimizedID=" + Request.QueryString("rowID"))%></h4>
            <%--<p>OperatingHospitalID: <%=Session("OperatingHospitalID").ToString%></p>--%>
<%--            <p>UserID: <%=Session("PKUserID").ToString%></p>--%>
<%--            <p>Group: <%=Request.QueryString("Group")%></p>
            <p>columnName: <%=Request.QueryString("columnName")%></p>
            <p>rowID: <%=Request.QueryString("rowID")%></p>
            <p>ReportID: <%=Request.QueryString("ReportID")%></p>--%>
            <p>
                <asp:GridView ID="GridView1" runat="server" AllowPaging="True" DataSourceID="DSPopUp"></asp:GridView>
            </p>
            <%--<telerik:RadGrid ID="RadGridPopUp" runat="server" AllowFilteringByColumn="True" AllowPaging="True" AllowSorting="True" GroupPanelPosition="Top" GridLines="Both" RenderMode="Lightweight">
                <ClientSettings AllowColumnsReorder="True" ReorderColumnsOnClient="True">
                    <Scrolling AllowScroll="True" UseStaticHeaders="True" />
                </ClientSettings>
                <MasterTableView AutoGenerateColumns="False">
                </MasterTableView>
            </telerik:RadGrid>--%>
            <asp:ObjectDataSource ID="DSPopUp" runat="server" SelectMethod="GetPopUpRows" TypeName="UnisoftERS.PopUp">
                <SelectParameters>
                    <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                    <asp:QueryStringParameter DefaultValue="NULL" Name="rowID" QueryStringField="rowID" Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>

        </div>
    </form>
</body>
</html>
