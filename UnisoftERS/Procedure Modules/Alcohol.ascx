<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Alcohol.ascx.vb" Inherits="UnisoftERS.Alcohol" %>

<telerik:RadCodeBlock runat="server">
    <script type="text/javascript">

        var sAlcoholPerdayText;
        $(window).on('load', function () {
            $("#<%=AlcoholStatusType.ClientId%>").change(function (e) {
                sAlcoholPerdayText = getAlcoholPerdayText();

                switch ($("#<%=AlcoholStatusType.ClientId%>").val()) {
                    case "Yes":
                        $("#AlcoholDescriptionDiv").attr("style", "display:block");
                        $("#AlcoholDescriptionDiv").find("#AlcoholperdayText").html(sAlcoholPerdayText);
                        $("#<%=AverageAlcoholPerDay.ClientId%>").val('');
                        $("#<%=AlcoholForYears.ClientId%>").val('');
                        $("#StoppedAlcoholDescriptionDiv").attr("style", "display:none");
                        $("#Alcoholbuttondiv").attr("style", "display:block");
                        break;

                    case 'Stopped':
                        $("#AlcoholDescriptionDiv").attr("style", "display:none");
                        $("#StoppedAlcoholDescriptionDiv").attr("style", "display:block");
                        $("#Alcoholbuttondiv").attr("style", "display:block");
                        $("#StoppedAlcoholDescriptionDiv").find("#stoppedAlcoholPerdayText").html(sAlcoholPerdayText);
                        $("#<%=StoppedAverageAlcohol.ClientID%>").val('');
                        $("#<%=AlcoholPerDay.ClientId%>").val('');
                        $("#<%=NoYearAlcohol.ClientId%>").val('');
                        break;
                    default:
                        $("#AlcoholDescriptionDiv").attr("style", "display:none");
                        $("#StoppedAlcoholDescriptionDiv").attr("style", "display:none");
                        $("#Alcoholbuttondiv").attr("style", "display:none");
                }
            });

            $("#<%=AlcoholTypedropdown.ClientId%>").change(function (e) {
                $("#AlcoholDescriptionDiv").attr("style", "display:none");
                $("#StoppedAlcoholDescriptionDiv").attr("style", "display:none");

                $("#Alcoholbuttondiv").attr("style", "display:none");

                clearAlcoholStatusInput()
            });

            function clearInput() {
                clearAlcoholStatusInput();
                clearAlcoholTypedropdown();
                $("#AlcoholDescriptionDiv").attr("style", "display:none");
                $("#StoppedAlcoholDescriptionDiv").attr("style", "display:none");
                $("#Alcoholbuttondiv").attr("style", "display:none");
            }

            function clearAlcoholStatusInput() {
                var combo = $find("<%=AlcoholStatusType.ClientId%>");
                combo.trackChanges();
                combo.get_items().getItem(0).select();
                combo.commitChanges();
            }

            function clearAlcoholTypedropdown() {
                var combo = $find("<%=AlcoholTypedropdown.ClientId%>");
                combo.trackChanges();
                combo.get_items().getItem(0).select();
                combo.commitChanges();
            }

            function getAlcoholPerdayText() {

                var SmokingTypedropdown = $find("<%=AlcoholTypedropdown.ClientId %>");
                var item = SmokingTypedropdown.get_selectedItem();

                return item.get_attributes().getAttribute("AlcoholingTypeAverageDescription");
            }

            function setAlcoholPerdayText() {
                var alcoholStatus = $("#<%=AlcoholStatusType.ClientId%>").val();
                if (alcoholStatus == 'Yes') {
                    $("#AlcoholDescriptionDiv").find("#AlcoholperdayText").html(sAlcoholPerdayText);

                }
                if (alcoholStatus == 'Stopped') {
                    $("#StoppedAlcoholDescriptionDiv").find("#AlcoholperdayText").html(sAlcoholPerdayText);
                }
            }

            $("#<%=btnAlcoholAdd.ClientId%>").click(function (e) {
                var smokingText;
                if ($("#<%=AlcoholStatusType.ClientId%>").val() == 'Yes') {
                    if ($("#<%=AverageAlcoholPerDay.ClientId%>").val() == '') {
                        $("#<%=AverageAlcoholPerDay.ClientId%>").focus();
                        alert("Enter Average Number");
                        return false;
                    }
                    if ($("#<%=AlcoholForYears.ClientId%>").val() == '') {
                        $("#<%=AlcoholForYears.ClientId%>").focus();
                        alert("Enter number of years");
                        return false;
                    }
                }

                if ($("#<%=AlcoholStatusType.ClientId%>").val() == 'Stopped') {
                    if ($("#<%=StoppedAverageAlcohol.ClientId%>").val() == '') {
                        $("#<%=StoppedAverageAlcohol.ClientId%>").focus();
                        alert("Enter Number of years smoked");
                        return false;
                    }
                    if ($("#<%=AlcoholPerDay.ClientId%>").val() == '') {
                        $("#<%=AlcoholPerDay.ClientId%>").focus();
                        alert("Enter number of smoked per day");
                        return false;
                    }
                    if ($("#<%=NoYearAlcohol.ClientId%>").val() == '') {
                        $("#<%=NoYearAlcohol.ClientId%>").focus();
                        alert("Enter number of years");
                        return false;
                    }
                }
                saveAlcohol();
            });

            $("#<%= btnAlcoholRemove.ClientId%>").click(function (e) {
                var alcoholLst = $find("<%= AlcoholLst.ClientID %>");
                if (alcoholLst.get_items().get_count() == 0) {
                    alert("There is no item to remove")
                    return false;
                }

                var item = alcoholLst.get_selectedItem();

                alcoholLst.trackChanges();
                alcoholLst.get_items().remove(item)
                alcoholLst.commitChanges()

                RemoveAlcohol(item.get_value())
                return false;
            });

            function saveAlcohol() {
                var obj = {};
                obj.procedureId = parseInt(<%=  Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID) %>);
                obj.PatientId = parseInt(getCookie('patientId'));
                var alcoholingTypeDropdown = $find("<%=AlcoholTypedropdown.ClientId%>");
                var AlcoholingTypeId = parseInt(alcoholingTypeDropdown.get_value());
                obj.AlcoholingTypeId = AlcoholingTypeId;
                obj.AlcoholingStatus = $("#<%=AlcoholStatusType.ClientId%>").val()
                if ($("#<%=AlcoholStatusType.ClientId%>").val() == 'Yes') {
                    obj.AverageAlcoholing = parseInt($("#<%=AverageAlcoholPerDay.ClientId%>").val());
                    obj.AlcoholingNoYear = parseInt($("#<%=AlcoholForYears.ClientId%>").val());

                    obj.AlcoholedQuitYears = 0;
                    obj.AlcoholedPerday = 0;
                    obj.AlcoholedNoYear = 0;
                }
                if ($("#<%=AlcoholStatusType.ClientId%>").val() == 'Stopped') {
                    obj.AlcoholedQuitYears = parseInt($("#<%=StoppedAverageAlcohol.ClientID%>").val());
                    obj.AlcoholedPerday = parseInt($("#<%=AlcoholPerDay.ClientId%>").val());
                    obj.AlcoholedNoYear = parseInt($("#<%=NoYearAlcohol.ClientId%>").val());
                    obj.AverageAlcoholing = 0;
                    obj.AlcoholingNoYear = 0;
                }

                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/saveAlcoholing",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function () {
                        setRehideSummary();
                        RefreshAlcoholList(AlcoholingTypeId);
                        clearInput();
                    },
                    error: function (x, y, z) {
                        //console.log(x.responseText);
                    }
                });
            }

            function RefreshAlcoholList(SmokingTypeId) {
                var obj = {};
                obj.procedureId = parseInt(<%=  Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID) %>);
                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/getAlcoholingDeatail",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        var objData = $.parseJSON(data.d);
                        var alcoholLst = $find("<%= AlcoholLst.ClientID %>");

                        alcoholLst.get_items().clear();
                        for (var j = 0; j < objData.length; j++) {
                            var item = new Telerik.Web.UI.RadListBoxItem();
                            item.set_text(objData[j][3]);
                            item.set_value(objData[j][0]);
                            item.bindTemplate()
                            alcoholLst.trackChanges();
                            alcoholLst.get_items().add(item);
                            if (SmokingTypeId == objData[j][1])
                                item.select();
                            alcoholLst.commitChanges();
                        }
                    },
                    error: function (x, y, z) {
                        //console.log(x.responseText);
                    }
                });
            }

            function RemoveAlcohol(ProcedureSmokingId) {
                var obj = {}
                obj.ProcedureSmokingId = ProcedureSmokingId;
                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/DeleteAlcoholing",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function () {
                        setRehideSummary();
                    },
                    error: function (x, y, z) {
                        //console.log(x.responseText);
                    }
                });
            }
        })
    </script>

</telerik:RadCodeBlock>
<div class="control-section-header abnorHeader">Alcohol Status</div>
<table>
    <tr>
        <td>
            <telerik:RadComboBox ID="AlcoholTypedropdown" DataTextField="AlcoholingTypeName" DataValueField="AlcoholingTypeId" runat="server" Skin="Windows7">
                <Items>
                    <telerik:RadComboBoxItem Text="" Value="0" Selected="true" />
                </Items>
            </telerik:RadComboBox>
        </td>
        <td>
            <telerik:RadComboBox runat="server" ID="AlcoholStatusType">
                <Items>
                    <telerik:RadComboBoxItem runat="server" Value="No" Text="" />
                    <telerik:RadComboBoxItem runat="server" Value="Yes" Text="Yes" />
                    <telerik:RadComboBoxItem runat="server" Value="Stopped" Text="Stopped" />
                </Items>
            </telerik:RadComboBox>
        </td>

        <td class="auto-style1">
            <div id="AlcoholDescriptionDiv" style="display: none">
                <span>Average</span>

                <telerik:RadNumericTextBox ID="AverageAlcoholPerDay" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span id="AlcoholperdayText"></span>
                &nbsp;
                <telerik:RadNumericTextBox ID="AlcoholForYears" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span>yrs</span>
            </div>

            <div id="StoppedAlcoholDescriptionDiv" style="display: none">
                <telerik:RadNumericTextBox ID="StoppedAverageAlcohol" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span>Years ago, but averaged</span>
                &nbsp;
                <telerik:RadNumericTextBox ID="AlcoholPerDay" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>

                <span id="stoppedAlcoholPerdayText"></span>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <telerik:RadNumericTextBox ID="NoYearAlcohol" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span id="StoppedYearsText">yrs</span>
            </div>
        </td>
        <td>
            <div id="Alcoholbuttondiv" style="display: none">
                <telerik:RadButton ID="btnAlcoholAdd" AutoPostBack="false" runat="server" Text="Add" Skin="WebBlue" Style=" margin-top: 3px;" />
            </div>
        </td>
    </tr>
</table>
<table>
    <tr>
        <td style="height: 72px">
            <telerik:RadListBox ID="AlcoholLst" runat="server" AutoPostBack="false" Width="500px" Height="200px" DataValueField="ProcedureAlcoholingId" DataKeyField="ProcedureAlcoholingId" DataTextField="AlcoholingDescription">
            </telerik:RadListBox>
        </td>
        <td style="height: 72px">
            <telerik:RadButton ID="btnAlcoholRemove" AutoPostBack="false" runat="server" Text="Remove" Skin="WebBlue" Style="margin-left: 0px; margin-top: 3px;" />
        </td>
    </tr>
</table>
