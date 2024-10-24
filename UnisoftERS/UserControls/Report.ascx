<%@ Control Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.UserControls_Report" Codebehind="Report.ascx.vb" %>

<asp:ObjectDataSource ID="SummaryObjectDataSource" runat="server" SelectMethod="GetReportSummary" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
<asp:ListView ID="SummaryListView" runat="server" DataSourceID="SummaryObjectDataSource">
    <LayoutTemplate>
        <table id="itemPlaceholderContainer" runat="server" border="0" class="rptSummaryText12" cellspacing="0" cellpadding="0">
            <tr id="itemPlaceholder" runat="server">
            </tr>
        </table>
    </LayoutTemplate>
    <ItemTemplate>
        <tr>
            <th align="left">
                <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" Font-Size="Small"  />
            </th>
        </tr>
        <tr>
            <td style="padding-left: 5px;">
                <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary")%>' Font-Size="Small"/>
            </td>
        </tr>
        <tr style="height: 10px">
            <td></td>
        </tr>
    </ItemTemplate>
</asp:ListView>

