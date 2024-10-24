<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OGDMean.aspx.vb" Inherits="UnisoftERS.OGDMean" %>
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
        .DrugName{
            min-width:65px;
            text-align:center;
        }
        .Dose{
            min-width:50px;
            text-align:center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="form1" />
    <div>
        <h4>Analysis for <%=GetValue("SELECT Consultant FROM v_rep_JAG_Consultants A, ERS_ReportConsultants B WHERE A.ReportID = B.ConsultantID And B.UserID="+Session("PKUserID").ToString+" And B.AnonimizedID="+Request.QueryString("rowID"))%></h4>
        <asp:ScriptManager ID="ScriptManager2" runat="server"></asp:ScriptManager>
        <telerik:RadGrid ID="RadGrid1" runat="server" CellSpacing="-1" DataSourceID="SqlDataSource1" GridLines="Both" GroupPanelPosition="Top" AllowPaging="True" AutoGenerateColumns="False">
            <GroupingSettings></GroupingSettings>
            <MasterTableView DataSourceID="SqlDataSource1">
                <Columns>
                    <telerik:GridBoundColumn DataField="Case note no" FilterControlAltText="Filter Case note no column" HeaderText="Case note no" ReadOnly="True" SortExpression="Case note no" UniqueName="CaseNoteNo">
                        <HeaderStyle CssClass="CaseNoteNo" HorizontalAlign="Center" />
                        <ItemStyle CssClass="CaseNoteNo" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Patient" FilterControlAltText="Filter Patient column" HeaderText="Patient" ReadOnly="True" SortExpression="Patient" UniqueName="Patient">
                        <HeaderStyle CssClass="PatientName" HorizontalAlign="Center" />
                        <ItemStyle CssClass="PatientName" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="DrugName" FilterControlAltText="Filter DrugName column" HeaderText="Drug Name" ReadOnly="True" SortExpression="DrugName" UniqueName="DrugName">
                        <HeaderStyle CssClass="DrugName" HorizontalAlign="Center" />
                        <ItemStyle CssClass="DrugName" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="Dose" DataType="System.Single" FilterControlAltText="Filter Dose column" HeaderText="Dose" ReadOnly="True" SortExpression="Dose" UniqueName="Dose">
                        <HeaderStyle CssClass="Dose" HorizontalAlign="Center" />
                        <ItemStyle CssClass="Dose" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="CreatedOn" FilterControlAltText="Filter CreatedOn column" HeaderText="Created On" ReadOnly="True" DataFormatString="{0:dd/MM/yyyy}" SortExpression="CreatedOn" UniqueName="CreatedOn" DataType="System.DateTime">
                        <HeaderStyle CssClass="CreatedOn" />
                        <ItemStyle CssClass="CreatedOn" />
                    </telerik:GridBoundColumn>
                    <telerik:GridBoundColumn DataField="ProcedureType" FilterControlAltText="Filter ProcedureType column" HeaderText="Proc. Type" ReadOnly="True" SortExpression="ProcedureType" UniqueName="ProcedureType">
                        <HeaderStyle CssClass="ProType" />
                        <ItemStyle CssClass="ProType" />
                    </telerik:GridBoundColumn>
                </Columns>
            </MasterTableView>
        </telerik:RadGrid>
        <asp:ObjectDataSource ID="SqlDataSource1" runat="server" SelectMethod="GetOGDMeanQry" TypeName="UnisoftERS.Reports">
            <SelectParameters>
                <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                <asp:QueryStringParameter DefaultValue="NULL" Name="rowID" QueryStringField="rowID" Type="String" />
            <asp:QueryStringParameter DefaultValue="NULL" Name="AgeLimit" QueryStringField="AgeLimit" />
            <asp:QueryStringParameter DefaultValue="NULL" Name="Drug" QueryStringField="Drug" />
            </SelectParameters>
        </asp:ObjectDataSource>
    </div>

    </form>
</body>
</html>
