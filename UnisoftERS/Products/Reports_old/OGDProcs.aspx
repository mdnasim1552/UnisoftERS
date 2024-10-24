<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OGDProcs.aspx.vb" Inherits="UnisoftERS.OGDProcs" %>

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
        .ProType{
            min-width:65px;
            text-align:center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="form1" />
    <div>
        <h4>Analysis for <%=GetValue("SELECT Consultant FROM v_rep_JAG_Consultants A, ERS_ReportConsultants B WHERE A.ReportID = B.ConsultantID And B.UserID=" + Session("PKUserID").ToString + " And B.AnonimizedID=" + Request.QueryString("rowID").ToString)%></h4>
        <asp:ScriptManager ID="ScriptManager2" runat="server"></asp:ScriptManager>
        <telerik:RadGrid ID="RadGrid1" runat="server" CellSpacing="-1" DataSourceID="SqlDataSource1" GridLines="Both" GroupPanelPosition="Top" AllowPaging="True" AutoGenerateColumns="False">
            <GroupingSettings></GroupingSettings>
            <MasterTableView DataSourceID="SqlDataSource1">
                <Columns>
                    <telerik:GridBoundColumn DataField="Case note no" FilterControlAltText="Filter Case note no column" HeaderText="Case note no" ReadOnly="True" SortExpression="Case note no" UniqueName="CaseNoteNo">
                        <ItemStyle CssClass="CaseNoteNo" />
                        <HeaderStyle CssClass="CaseNoteNo" HorizontalAlign="Center" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Patient" FilterControlAltText="Filter Patient column" HeaderText="Patient Name" ReadOnly="True" SortExpression="Patient" UniqueName="Patient">
                        <ItemStyle CssClass="PatientName" />
                        <HeaderStyle CssClass="PatientName" HorizontalAlign="Center" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="DateofBirth" FilterControlAltText="Filter DateofBirth column" HeaderText="D.O.B." ReadOnly="True" SortExpression="DateofBirth" DataFormatString="{0:dd/MM/yyyy}" UniqueName="DateofBirth">
                        <HeaderStyle HorizontalAlign="Center" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="CreatedOn" DataType="System.DateTime" FilterControlAltText="Filter CreatedOn column" HeaderText="Created On" ReadOnly="True" DataFormatString="{0:dd/MM/yyyy}" SortExpression="CreatedOn" UniqueName="CreatedOn">
                        <HeaderStyle CssClass="CreatedOn" />
                        <ItemStyle CssClass="CreatedOn" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="ProcedureType" FilterControlAltText="Filter ProcedureType column" HeaderText="Pro. Type" ReadOnly="True" SortExpression="ProcedureType" UniqueName="ProcedureType">
                        <ItemStyle CssClass="ProType" />
                        <HeaderStyle CssClass="ProType" HorizontalAlign="Center" />
                    </telerik:GridBoundColumn>
                </Columns>
            </MasterTableView>
        </telerik:RadGrid>
        <asp:ObjectDataSource ID="SqlDataSource1" runat="server" SelectMethod="GetOGDProcsQry" TypeName="UnisoftERS.Reports">
                <SelectParameters>
                    <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                    <asp:QueryStringParameter DefaultValue="NULL" Name="rowID" QueryStringField="rowID" Type="String" />
                </SelectParameters>
            </asp:ObjectDataSource>
<%--        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:Gastro_DB %>" SelectCommand="Select [Case note no],[Forename]+' '+[Surname] As Patient, DateofBirth, ProcedureID, CreatedOn, ProcedureType, Release
From [dbo].[v_rep_JAG_ProcsUGIOGD] Procs, ERS_ReportFilter ERF, v_rep_JAG_ReportConsultants ERC
Where Release='UGI' And ERF.UserID=@UserID And ERF.UserID=ERC.UserID And ERC.AnonimizedID=@rowID
	And ([CreatedOn]&gt;=ERF.FromDate And [CreatedOn]&lt;=ERF.ToDate) 
	And ((Endoscopist1=ERC.UGIID) Or (Endoscopist2=ERC.UGIID) Or (Assistant1=ERC.UGIID) Or (ListConsultant=ERC.UGIID) Or (Nurse1=ERC.UGIID) Or (Nurse2=ERC.UGIID) Or (Nurse3=ERC.UGIID))
Union All
Select [Case note no],[Forename]+' '+[Surname] As Patient, DateofBirth, ProcedureID, CreatedOn, ProcedureType, Release 
From [dbo].[v_rep_JAG_ProcsERSOGD] Procs, ERS_ReportFilter ERF, v_rep_JAG_ReportConsultants ERC
Where Release='ERS' And ERF.UserID=@UserID And ERF.UserID=ERC.UserID And ERC.AnonimizedID=@rowID
	And ([CreatedOn]&gt;=ERF.FromDate And [CreatedOn]&lt;=ERF.ToDate) 
	And ((Endoscopist1=ERC.ERSID) Or (Endoscopist2=ERC.ERSID) Or (Assistant1=ERC.ERSID) Or (ListConsultant=ERC.ERSID) Or (Nurse1=ERC.ERSID) Or (Nurse2=ERC.ERSID) Or (Nurse3=ERC.ERSID))">
            <SelectParameters>
                <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                <asp:QueryStringParameter DefaultValue="NULL" Name="RowID" QueryStringField="rowID" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>--%>
    </div>
    </form>
</body>
</html>
