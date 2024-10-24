<%@ Page Language="vb" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" CodeBehind="FreeSlotDefaults.aspx.vb" Inherits="UnisoftERS.FreeSlotDefaults" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title></title>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    bindEvents();
                });
            });

            function bindEvents() {
                $('.default-days input[type=checkbox]').on('click', function () {
                    var idVal = $(this).attr("id");
                    var day = $(this).closest('tr').attr('data-day');

                    if ((($("label[for='" + idVal + "']").text().toLowerCase()) == day)) {
                        var isChecked = ($(this).is(":checked"));
                        $('[data-day=' + day + '] input[type=checkbox]').each(function (index, item) {
                            $(item).prop("checked", isChecked);
                        });
                    }
                    else {
                        //count how many checkboxes on that day are checked
                        var checkedCount = 0;
                        
                        $('[data-day=' + day + '] input[type=checkbox]').each(function (index, item) {
                            var ctrlId = $(item).attr("id");
                            if (($("label[for='" + ctrlId + "']").text().toLowerCase()) != day) {
                                if ($(this).is(':checked')) {
                                    checkedCount++;
                                }
                            }

                        });

                        if (checkedCount > 0)
                            $('tr [data-day=' + day + '] input[type=checkbox]').first().prop("checked", true);
                        else
                            $('tr [data-day=' + day + '] input[type=checkbox]').first().prop("checked", false);
                    }
                });
            }

        </script>
    </telerik:RadScriptBlock>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Set Free Slots Defaults"></asp:Label>
    </div>


    <div id="FormDiv" style="margin-top: 10px; width: 700px;">
        <div id="FilterBox" class="optionsBodyText" style="margin-left: 10px; width: 556px">
            <div style="padding-top: 10px; padding-left: 12px;">
                Hospital:
                    <telerik:RadComboBox ID="HospitalsComboBox" runat="server" Skin="Metro" AutoPostBack="true" Width="270" OnSelectedIndexChanged="HospitalsComboBox_SelectedIndexChanged" />
            </div>
        </div>

        <fieldset id="otherDataFieldset" runat="server">
            <table width="95%">
                <tr>
                    <td colspan="2">
                        <div style="margin-top: 5px; margin-left: 10px; height: 100px; width: 95%;" class="optionsBodyText">
                            <asp:Panel ID="Panel3" runat="server" GroupingText="Please Note">
                                <table style="width: 100%; padding-left: 10px;">
                                    <tr>
                                        <td style="padding-top: 10px; padding-left: 10px; width: 10%;"></td>
                                        <td style="padding-top: 10px; width: 100%;">
                                            <asp:Label runat="server" ID="Label1">Use this window to build up the default days that are used when searching for free slots.
                                            </asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td valign="top">
                        <div>
                            <table id="DefaultSlotsTable" runat="server" class="default-days" cellpadding="4">
                                <tr>
                                    <td></td>
                                    <td>
                                        <label>Morning</label></td>
                                    <td>
                                        <label>Afternoon</label></td>
                                    <td>
                                        <label>Evening</label></td>
                                </tr>
                                <tr data-day="monday">
                                    <td>
                                        <asp:CheckBox ID="MondayCheckBox" runat="server" Text="Monday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="MondayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="MondayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="MondayEveningCheckBox" runat="server" /></td>
                                </tr>
                                <tr data-day="tuesday">
                                    <td>
                                        <asp:CheckBox ID="TuesdayCheckBox" runat="server" Text="Tuesday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="TuesdayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="TuesdayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="TuesdayEveningCheckBox" runat="server" /></td>
                                </tr>
                                <tr data-day="wednesday">
                                    <td>
                                        <asp:CheckBox ID="WednesdayCheckBox" runat="server" Text="Wednesday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="WednesdayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="WednesdayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="WednesdayEveningCheckBox" runat="server" /></td>
                                </tr>
                                <tr data-day="thursday">
                                    <td>
                                        <asp:CheckBox ID="ThursdayCheckBox" runat="server" Text="Thursday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="ThursdayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="ThursdayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="ThursdayEveningCheckBox" runat="server" /></td>
                                </tr>
                                <tr data-day="friday">
                                    <td>
                                        <asp:CheckBox ID="FridayCheckBox" runat="server" Text="Friday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="FridayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="FridayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="FridayEveningCheckBox" runat="server" /></td>
                                </tr>
                                <tr data-day="saturday">
                                    <td>
                                        <asp:CheckBox ID="SaturdayCheckBox" runat="server" Text="Saturday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="SaturdayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="SaturdayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="SaturdayEveningCheckBox" runat="server" /></td>
                                </tr>
                                <tr data-day="sunday">
                                    <td>
                                        <asp:CheckBox ID="SundayCheckBox" runat="server" Text="Sunday" TextAlign="Right" CssClass="day-cb" /></td>
                                    <td>
                                        <asp:CheckBox ID="SundayMorningCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="SundayAfternoonCheckBox" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="SundayEveningCheckBox" runat="server" /></td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
            <div>
                <table>
                    <tr>
                        <td>
                            <telerik:RadButton ID="SaveRadButton" runat="server" Text="Save" AutoPostBack="True" OnClick="SaveRadButton_Click" Icon-PrimaryIconCssClass="telerikSaveButton" />
                        </td>

                        <td>
                            <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" Skin="Web20" AutoPostBack="True" Icon-PrimaryIconCssClass="telerikCancelButton" />
                        </td>
                    </tr>
                </table>
            </div>
        </fieldset>
    </div>
</asp:Content>
