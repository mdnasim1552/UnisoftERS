<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Smoking.ascx.vb" Inherits="UnisoftERS.Smoking" %>
<telerik:RadCodeBlock runat="server">
    <script type="text/javascript">
      
        var sPerdayText;
        $(window).on('load', function () {
            $("#<%=SmokingStatusType.ClientId%>").change(function (e) {
                sPerdayText = getPerdayText();

                switch ($("#<%=SmokingStatusType.ClientId%>").val()) {
                    case "Yes":
                        $("#smokingDescriptionDiv").attr("style", "display:block");
                        $("#smokingDescriptionDiv").find("#perdayText").html(sPerdayText);
                        $("#<%=AverageSmokePerDay.ClientId%>").val('');
                        $("#<%=SmokeForYears.ClientId%>").val('');
                        $("#StoppedsmokingDescriptionDiv").attr("style", "display:none");
                        $("#buttondiv").attr("style", "display:block");
                        break;

                    case 'Stopped':
                        $("#smokingDescriptionDiv").attr("style", "display:none");
                        $("#StoppedsmokingDescriptionDiv").attr("style", "display:block");
                        $("#buttondiv").attr("style", "display:block");
                        $("#StoppedsmokingDescriptionDiv").find("#stoppedPerdayText").html(sPerdayText);
                        $("#<%=StoppedAverageSmoked.ClientID%>").val('');
                        $("#<%=SmokedPerDay.ClientId%>").val('');
                        $("#<%=NoYearSmoked.ClientId%>").val('');
                        break;
                    default:
                        $("#smokingDescriptionDiv").attr("style", "display:none");
                        $("#StoppedsmokingDescriptionDiv").attr("style", "display:none");
                        $("#buttondiv").attr("style", "display:none");
                }
            });

            $("#<%=SmokingTypedropdown.ClientId%>").change(function (e) {
                $("#smokingDescriptionDiv").attr("style", "display:none");
                $("#StoppedsmokingDescriptionDiv").attr("style", "display:none");

                $("#buttondiv").attr("style", "display:none");

                clearSmokingStatusInput()
            });

            function clearInput() {
                clearSmokingStatusInput();
                clearSmokingTypedropdown();
                $("#smokingDescriptionDiv").attr("style", "display:none");
                $("#StoppedsmokingDescriptionDiv").attr("style", "display:none");
                $("#buttondiv").attr("style", "display:none");
            }

            function clearSmokingStatusInput() {
                 var combo = $find("<%=SmokingStatusType.ClientId%>");
                combo.trackChanges();
                combo.get_items().getItem(0).select();
                combo.commitChanges();
            }

            function clearSmokingTypedropdown() {
                 var combo = $find("<%=SmokingTypedropdown.ClientId%>");
                combo.trackChanges();
                combo.get_items().getItem(0).select();
                combo.commitChanges();
            }

            function getPerdayText() {

                var SmokingTypedropdown = $find("<%=SmokingTypedropdown.ClientId %>");
                var item = SmokingTypedropdown.get_selectedItem();

                return item.get_attributes().getAttribute("SmokingTypeAverageDescription");
            }

            function setPerdayText() {

                var smokeingStatus = $("#<%=SmokingStatusType.ClientId%>").val();
                if (smokeingStatus == 'Yes') {
                    $("#smokingDescriptionDiv").find("#perdayText").html(sPerdayText);

                }
                if (smokeingStatus == 'Stopped') {
                    $("#StoppedsmokingDescriptionDiv").find("#perdayText").html(sPerdayText);
                }
            }

            $("#<%=btnSmokingAdd.ClientId%>").click(function (e) {
                var smokingText;
                if ($("#<%=SmokingStatusType.ClientId%>").val() == 'Yes') {
                    if ($("#<%=AverageSmokePerDay.ClientId%>").val() == '') {
                        $("#<%=AverageSmokePerDay.ClientId%>").focus();
                        alert("Enter Average Number");
                        return false;
                    }
                    if ($("#<%=SmokeForYears.ClientId%>").val() == '') {
                        $("#<%=SmokeForYears.ClientId%>").focus();
                        alert("Enter number of years");
                        return false;
                    }
                }

                if ($("#<%=SmokingStatusType.ClientId%>").val() == 'Stopped') {
                    if ($("#<%=StoppedAverageSmoked.ClientId%>").val() == '') {
                        $("#<%=StoppedAverageSmoked.ClientId%>").focus();
                        alert("Enter Number of years smoked");
                        return false;
                    }
                    if ($("#<%=SmokedPerDay.ClientId%>").val() == '') {
                        $("#<%=SmokedPerDay.ClientId%>").focus();
                        alert("Enter number of smoked per day");
                        return false;
                    }
                    if ($("#<%=NoYearSmoked.ClientId%>").val() == '') {
                        $("#<%=NoYearSmoked.ClientId%>").focus();
                        alert("Enter number of years");
                        return false;
                    }
                }
                saveSmoking();
            });

            $("#<%= btnSmokingRemove.ClientId%>").click(function (e) {
                var smokimgLst = $find("<%= SmokingLst.ClientID %>");
                if (smokimgLst.get_items().get_count() == 0) {
                    alert("There is no item to remove")
                    return false;
                }

                var item = smokimgLst.get_selectedItem();
              
                smokimgLst.trackChanges();
                smokimgLst.get_items().remove(item)
                smokimgLst.commitChanges()

                RemoveSmoking(item.get_value())
                return false;
            });

            function saveSmoking() {
                var obj = {};
                obj.procedureId = parseInt(<%=  Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID) %>);
                obj.PatientId = parseInt(getCookie('patientId'));
                var smokingTypeDropdown = $find("<%=SmokingTypedropdown.ClientId%>");
                var SmokingTypeId = parseInt(smokingTypeDropdown.get_value());
                obj.SmokingTypeId = SmokingTypeId;
                obj.SmokingStatus = $("#<%=SmokingStatusType.ClientId%>").val()
                if ($("#<%=SmokingStatusType.ClientId%>").val() == 'Yes') {
                    obj.AverageSmoking = parseInt($("#<%=AverageSmokePerDay.ClientId%>").val());
                   obj.SmokingNoYear=parseInt($("#<%=SmokeForYears.ClientId%>").val());

                    obj.SmokedQuitYears = 0;
                    obj.SmokedPerday = 0;
                    obj.SmokedNoYear = 0;
                }
                if ($("#<%=SmokingStatusType.ClientId%>").val() == 'Stopped') {
                    obj.SmokedQuitYears = parseInt($("#<%=StoppedAverageSmoked.ClientID%>").val());
                    obj.SmokedPerday = parseInt($("#<%=SmokedPerDay.ClientId%>").val());
                    obj.SmokedNoYear = parseInt($("#<%=NoYearSmoked.ClientId%>").val());
                    obj.AverageSmoking = 0;
                    obj.SmokingNoYear = 0;
                }

                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/saveSmoking",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function () {
                        setRehideSummary();
                        RefreshSmokingList(SmokingTypeId);
                        clearInput();
                    },
                    error: function (x, y, z) {
                        //console.log(x.responseText);
                    }
                });
            }

            function RefreshSmokingList(SmokingTypeId) {
                var obj = {};
                obj.procedureId = parseInt(<%=  Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID) %>);
                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/getSmokingDeatail",
                    data: JSON.stringify(obj),
                    dataType: "json",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        var objData = $.parseJSON(data.d);
                        var smokimgLst = $find("<%= SmokingLst.ClientID %>");

                         smokimgLst.get_items().clear();
                         for (var j = 0; j < objData.length; j++) {
                             var item = new Telerik.Web.UI.RadListBoxItem();
                             item.set_text(objData[j][3]);
                             item.set_value(objData[j][0]);
                             item.bindTemplate()
                             smokimgLst.trackChanges();
                             smokimgLst.get_items().add(item);
                             if (SmokingTypeId == objData[j][1])
                                 item.select();
                             smokimgLst.commitChanges();
                         }
                     },
                     error: function (x, y, z) {
                         //console.log(x.responseText);
                     }
                 });
            }

            function RemoveSmoking(ProcedureSmokingId) {
                var obj = {}
                obj.ProcedureSmokingId = ProcedureSmokingId;
                $.ajax({
                    type: "POST",
                    url: "PreProcedure.aspx/DeleteSmoking",
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
<div class="control-section-header abnorHeader">Smoking Status</div>
<table>
    <tr>
        <td>
            <telerik:RadComboBox ID="SmokingTypedropdown" DataTextField="SmokingTypeName" DataValueField="SmokingTypeId" runat="server" Skin="Windows7"></telerik:RadComboBox>
        </td>
        <td>
            <telerik:RadComboBox runat="server" ID="SmokingStatusType">
                <Items>
                    <telerik:RadComboBoxItem runat="server" Value="No" Text="" />
                    <telerik:RadComboBoxItem runat="server" Value="Yes" Text="Yes" />
                    <telerik:RadComboBoxItem runat="server" Value="Stopped" Text="Stopped" />
                </Items>
            </telerik:RadComboBox>
        </td>

        <td class="auto-style1">
            <div id="smokingDescriptionDiv" style="display: none">
                <span>Average</span>

                <telerik:RadNumericTextBox ID="AverageSmokePerDay" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span id="perdayText"></span>
                &nbsp;
                <telerik:RadNumericTextBox ID="SmokeForYears" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span style="margin-left: -5px;">yrs</span>
            </div>

            <div id="StoppedsmokingDescriptionDiv" style="display: none">
                <telerik:RadNumericTextBox ID="StoppedAverageSmoked" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span>Years ago, but averaged</span>
                &nbsp;
                <telerik:RadNumericTextBox ID="SmokedPerDay" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
               
                <span style="margin-left: -5px;" id="stoppedPerdayText"></span>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <telerik:RadNumericTextBox ID="NoYearSmoked" runat="server"
                    IncrementSettings-InterceptMouseWheel="false"
                    IncrementSettings-Step="1"
                    Width="35px"
                    MinValue="0">
                    <NumberFormat DecimalDigits="0" />
                </telerik:RadNumericTextBox>
                <span style="margin-left: -5px;" id="StoppedYearsText">yrs</span>
            </div>
        </td>
        <td>
            <div id="buttondiv" style="display: none">
                <telerik:RadButton ID="btnSmokingAdd" AutoPostBack="false" runat="server" Text="Add" Skin="WebBlue" Style="margin-left: 0px; margin-top: 3px;" />
            </div>
        </td>
    </tr>
</table>
<table>
    <tr>
        <td style="height: 72px">
            <telerik:RadListBox ID="SmokingLst" runat="server" AutoPostBack="false" Width="500px" Height="200px" DataValueField="ProcedureSmokingId" DataKeyField="ProcedureSmokingId" DataTextField="SmokingDescription">
            </telerik:RadListBox>
        </td>
        <td style="height: 72px">
            <telerik:RadButton ID="btnSmokingRemove" AutoPostBack="false" runat="server" Text="Remove" Skin="WebBlue" Style="margin-left: 0px; margin-top: 3px;" />
        </td>
    </tr>
</table>
