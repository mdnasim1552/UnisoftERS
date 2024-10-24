<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OGDAudit.aspx.vb" Inherits="UnisoftERS.OGDAudit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%=Request.QueryString("title")%></title>
    <style type="text/css">
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
        .PatientDisComfort{
            min-width:120px;
            text-align:center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="form1" />
    <div>
        <h4>Analysis for <%=GetValue("SELECT Consultant FROM v_rep_JAG_Consultants A, ERS_ReportConsultants B WHERE A.ReportID = B.ConsultantID And B.UserID="+Session("PKUserID").ToString+" And B.AnonimizedID="+Request.QueryString("EndoscopistID"))%></h4>
        <asp:ScriptManager ID="ScriptManager2" runat="server"></asp:ScriptManager>
        <telerik:RadGrid ID="RadGrid1" runat="server" CellSpacing="-1" DataSourceID="SqlDataSource1" GridLines="Both" GroupPanelPosition="Top" AllowPaging="True" AutoGenerateColumns="False">
            <GroupingSettings></GroupingSettings>
            <MasterTableView DataSourceID="SqlDataSource1">
                <Columns>
                    <telerik:GridBoundColumn DataField="CasenoteNo" FilterControlAltText="Filter CasenoteNo column" HeaderText="Case Note No" SortExpression="CasenoteNo" UniqueName="CasenoteNo">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Patient" FilterControlAltText="Filter Patient column" HeaderText="Patient" SortExpression="Patient" UniqueName="Patient">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Endoscopist1" FilterControlAltText="Filter Endoscopist1 column" HeaderText="Endoscopist 1" SortExpression="Endoscopist1" UniqueName="Endoscopist1">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Endoscopist2" FilterControlAltText="Filter Endoscopist2 column" HeaderText="Endoscopist 2" SortExpression="Endoscopist2" UniqueName="Endoscopist2">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Assistant1" FilterControlAltText="Filter Assistant1 column" HeaderText="Assistant 1" SortExpression="Assistant1" UniqueName="Assistant1">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="ListConsultant" FilterControlAltText="Filter ListConsultant column" HeaderText="List Consultant" SortExpression="ListConsultant" UniqueName="ListConsultant">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Nurse1" FilterControlAltText="Filter Nurse1 column" HeaderText="Nurse1" SortExpression="Nurse 1" UniqueName="Nurse1">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Nurse2" FilterControlAltText="Filter Nurse2 column" HeaderText="Nurse2" SortExpression="Nurse 2" UniqueName="Nurse2">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="PatDisconform" DataType="System.Int32" FilterControlAltText="Filter PatDisconform column" HeaderText="Pat Disconform >4" SortExpression="PatDisconform" UniqueName="PatDisconform">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="LT70" DataType="System.Int32" FilterControlAltText="Filter LT70 column" HeaderText="&lt;70" SortExpression="LT70" UniqueName="LT70">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="GE70" DataType="System.Int32" FilterControlAltText="Filter GE70 column" HeaderText="≥70" SortExpression="GE70" UniqueName="GE70">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Midazolam" DataType="System.Int32" FilterControlAltText="Filter Midazolam column" HeaderText="Midazolam" SortExpression="Midazolam" UniqueName="Midazolam">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Pethidine" DataType="System.Int32" FilterControlAltText="Filter Pethidine column" HeaderText="Pethidine" SortExpression="Pethidine" UniqueName="Pethidine">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Fentanyl" DataType="System.Int32" FilterControlAltText="Filter Fentanyl column" HeaderText="Fentanyl" SortExpression="Fentanyl" UniqueName="Fentanyl">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Placements" DataType="System.Int32" FilterControlAltText="Filter Placements column" HeaderText="Placements" SortExpression="Placements" UniqueName="Placements">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="IncorrectPlacement" DataType="System.Int32" FilterControlAltText="Filter IncorrectPlacement column" HeaderText="IncorrectPlacement" SortExpression="IncorrectPlacement" UniqueName="IncorrectPlacement">
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="CorrectPlacement" DataType="System.Int32" FilterControlAltText="Filter CorrectPlacement column" HeaderText="CorrectPlacement" SortExpression="CorrectPlacement" UniqueName="CorrectPlacement">
                    </telerik:GridBoundColumn>
                </Columns>
            </MasterTableView>
        </telerik:RadGrid>
        <asp:ObjectDataSource ID="SqlDataSource1" runat="server" SelectMethod="GetAuditQry" TypeName="UnisoftERS.Reports">
            <SelectParameters>
                <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                <asp:QueryStringParameter DefaultValue="NULL" Name="rowID" QueryStringField="rowID" Type="String" />
            </SelectParameters>
        </asp:ObjectDataSource>
    </div>
    </form>
</body>
</html>
