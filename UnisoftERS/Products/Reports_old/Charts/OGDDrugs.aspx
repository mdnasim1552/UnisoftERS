<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OGDDrugs.aspx.vb" Inherits="UnisoftERSViewer.OGDDrugs" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Charting" Assembly="Telerik.Web.UI" %>
<telerik:RadSkinManager ID="RadSkinManager2" runat="server" Skin="Windows7" />
<telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="raddeco" />
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager runat="server"></telerik:RadScriptManager>
    <telerik:RadAjaxLoadingPanel runat="server" ID="LoaderPanel" />
    <div id="raddeco" style="margin-left: 15px; padding-bottom : 20px">
        <telerik:RadHtmlChart runat="server" ID="RadHtmlChartW" BorderStyle="Solid" BorderColor="#F5F5F5" BorderWidth="1" Width="700px" Skin="Silk" Height="500px" DataSourceID="ObjectDataSource1">
            <PlotArea>
                <Series>
                    <telerik:ColumnSeries DataFieldY="Dose">
                        <TooltipsAppearance Color="White" />
                    </telerik:ColumnSeries>
                </Series>
                <XAxis DataLabelsField="DrugName">
                    <TitleAppearance Text="Drug Name">
                        <TextStyle Margin="20" />
                    </TitleAppearance>
                    <MajorGridLines Visible="false" />
                    <MinorGridLines Visible="false" />
                </XAxis>
                <YAxis>
                    <TitleAppearance Text="Mean of dose">
                        <TextStyle Margin="20" />
                    </TitleAppearance>
                    <MinorGridLines Visible="false" />
                </YAxis>
            </PlotArea>
            <ChartTitle Text="Drugs means in premedication">
            </ChartTitle>
        </telerik:RadHtmlChart>
        <asp:ObjectDataSource ID="ObjectDataSource1" runat="server" TypeName="UnisoftERSViewer.Charts" SelectMethod="GetOGDDrugs"></asp:ObjectDataSource>
    </div>
    </form>
</body>
</html>

