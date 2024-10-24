<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="dashboard.ascx.vb" Inherits="UnisoftERS.dashboard" %>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Charting" Assembly="Telerik.Web.UI" %>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Windows7" />
    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="raddeco" />
<telerik:RadAjaxLoadingPanel runat="server" ID="LoaderPanel" Skin="Metro" />
<div id="raddeco" style="margin-left: 0px; padding-bottom : 20px">
    <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server" LoadingPanelID="LoaderPanel">
        <telerik:RadContextMenu ID="OptionsMenu1" Skin="Web20" runat="server" EnableRoundedCorners="True" EnableShadows="True" EnableSelection ="true" OnItemClick="OptionMenuClicked">
            <Targets>
                <telerik:ContextMenuControlTarget ControlID="RadHtmlChart1" />
               </Targets>
            <Items>
               <telerik:RadMenuItem Text="Chart" > 
                   <Items >
                       <telerik:RadMenuItem Text="Column Chart" Value="ColumnSeries"/>
                       <telerik:RadMenuItem Text="Bar Chart" Value ="BarSeries"/>
                       <telerik:RadMenuItem Text="Line Chart" Value="LineSeries"/>                       
 <%--                      <telerik:RadMenuItem Text="Scatter Chart"  Value ="ScatterSeries"/>
                       <telerik:RadMenuItem Text="Area Chart" Value="AreaSeries"/>--%>
                   </Items>                   
                </telerik:RadMenuItem>
            </Items>
        </telerik:RadContextMenu>
        <telerik:RadContextMenu ID="OptionsMenu2" Skin="Web20" runat="server" EnableRoundedCorners="True" EnableShadows="True" EnableSelection="true" OnItemClick="OptionMenuClicked">
            <Targets>
                <telerik:ContextMenuControlTarget ControlID="RadHtmlChart2" />
            </Targets>
            <Items>
                <telerik:RadMenuItem Text="Year" />                
                <telerik:RadMenuItem IsSeparator="true"/>
                <telerik:RadMenuItem Text="Chart">   
                    <Items>
                       <telerik:RadMenuItem Text="Column Chart" Value="ColumnSeries"/>
                       <telerik:RadMenuItem Text="Bar Chart" Value ="BarSeries"/>
                       <telerik:RadMenuItem Text="Line Chart" Value="LineSeries"/>                       
   <%--                    <telerik:RadMenuItem Text="Scatter Chart"  Value ="ScatterSeries"/>
                       <telerik:RadMenuItem Text="Area Chart" Value="AreaSeries"/>      --%>                  
                   </Items>                    
                </telerik:RadMenuItem>
            </Items>
        </telerik:RadContextMenu>
        <table id="tablesTiles" runat="server" cellspacing="0" cellpadding="0" border="0" style="table-layout: fixed; width: 97% !important;">
            <tr>
                <td colspan="1">
                    <%--<telerik:RadChart ID="chartViewer" runat="server" Skin="Web20"  DataSourceID="chartdataobject" Width="600px" ChartTitle-TextBlock-Appearance-TextProperties-Font="Segoe UI, 12pt" OnItemDataBound="ItemDataBound" >
                    <Appearance>
                        <FillStyle MainColor="255, 255, 244" />
                        <Border Color="White" />
                    </Appearance>
                </telerik:RadChart>--%>



                   <telerik:RadHtmlChart runat="server" ID="RadHtmlChart1" BorderStyle="Solid" BorderColor="#F5F5F5"
                            BorderWidth="1" Skin="Windows7" Height="350px" style="width:100% !important;">
                     <Appearance>
                         <FillStyle BackgroundColor="250, 250, 250"/>
                      </Appearance>


                    <PlotArea>
                        <XAxis DataLabelsField="ProductName">
                            <MajorGridLines Visible="false"></MajorGridLines>
                            <MinorGridLines Visible="false"></MinorGridLines>
                        </XAxis>
                        <YAxis>
                            <MajorGridLines Color="#F0F0F0" ></MajorGridLines>
                            <MinorGridLines Visible="false"></MinorGridLines>
                        </YAxis>
                    </PlotArea>


                     <ChartTitle Text="Procedures over the years"><Appearance Align="Center"><TextStyle FontFamily="Segoe UI, 12pt" /></Appearance></ChartTitle>
                     <Legend >
                         <Appearance Position="Bottom" BackgroundColor="#F1F1F1">
                             <TextStyle FontFamily="Segoe UI, 12pt" Italic="true"/>
                         </Appearance>
                     </Legend>
                  </telerik:RadHtmlChart>

                    

                </td>
                <td style="padding-left:20px;" colspan="1">
                    <%--<telerik:RadChart ID="RadCharty" runat="server" Skin="Web20"  DataSourceID="chartdataobjectmonth" Width="600px" ChartTitle-TextBlock-Appearance-TextProperties-Font="Segoe UI, 12pt" OnItemDataBound="ItemDataBound">
                    <Appearance>
                        <FillStyle MainColor="255, 255, 244" />
                        <Border Color="White" />
                    </Appearance>

                </telerik:RadChart>--%>

                    <telerik:RadHtmlChart runat="server" ID="RadHtmlChart2" BorderStyle="Solid" BorderColor="#F5F5F5" 
                            BorderWidth="1" style="width:100% !important;" Skin="Windows7" Height="350px">
                        <Appearance>
                            <FillStyle BackgroundColor="250, 250, 250"/>
                        </Appearance>
                        <PlotArea>
                            <XAxis DataLabelsField="ProductName">
                                <MajorGridLines Visible="false"></MajorGridLines>
                                <MinorGridLines Visible="false"></MinorGridLines>
                            </XAxis>
                            <YAxis>
                                <MajorGridLines Color="#F0F0F0" ></MajorGridLines>
                                <MinorGridLines Visible="false"></MinorGridLines>
                            </YAxis>
                        </PlotArea>
                        <ChartTitle Text="Procedures over the years">
                            <Appearance Align="Center">
                                <TextStyle FontFamily="Segoe UI, 12pt" />
                            </Appearance>
                        </ChartTitle>
                        <Legend>
                            <Appearance Position="Bottom" BackgroundColor="#F1F1F1">
                                <TextStyle FontFamily="Segoe UI, 12pt" Italic="true"  />
                            </Appearance>
                        </Legend>
                    </telerik:RadHtmlChart>
                </td>
            </tr>
            <tr id="trChartErrorLabel" runat="server" visible="false">
                <td colspan="2" style="align-content:center;text-align:center;vertical-align:baseline;font-size:1.2em;">
                    <img src="../Images/warning-24x24.png" style="vertical-align:top;" />&nbsp;&nbsp;The chart couldn't be loaded at the moment! Please try again later.</td>
            </tr>
            <tr >
                <td style="padding-top:20px;" class="border_bottom"></td>
                <td class="border_bottom"></td>
            </tr>
        </table>
    </telerik:RadAjaxPanel>
</div>