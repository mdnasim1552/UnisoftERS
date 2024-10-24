<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="OrderCommsReportForPdf.aspx.vb" Inherits="UnisoftERS.OrderCommsReportForPdf" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        .forceMetroSkin {
            color: #333;
            font-family: "Segoe UI",Arial, Helvetica, sans-serif;
            font-size: 12px;
        }
        .hrnormal{
            border:none;
            height:1px;
            color:#333;
            background-color:#333;
        }
        .hrdotted{
            border: 1px dotted #0094ff;
        }
        tr,th,td{
            vertical-align:top!important;
            color: #333;
            font-family: "Segoe UI",Arial, Helvetica, sans-serif;
            font-size: 12px;
        }
        h2,h3{
            color:navy;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="forceMetroSkin">
            <table border="0" style="width:100%;vertical-align:top!important;padding:0px 0px 0px 0px;" class="forceMetroSkin">
                <tr>
                    <td>
                        <h2 style="text-align:center;">ORDER DETAILS</h2>
                        <hr class="hrnormal" />
                    </td>
                </tr>
                <tr>
                    <td style="vertical-align:top!important;">
                        <h3>Patient Information:</h3>
                        <br />
                        <table border="0" style="vertical-align:top!important;padding:0px 0px 0px 0px;">
                            <tr style="vertical-align:top!important;">                                
                                <td style="width:150px;">Name:</td>
                                <td style="width:150px;">
                                    <asp:Label runat="server" ID="OrderDetailPatName" /></td>
                                <td rowspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                <td rowspan="5" style="vertical-align:top!important;"></td>
                                <td rowspan="2" style="vertical-align:top!important;"><b>Address:</b><br />
                                    <asp:Label runat="server" ID="OrderDetailPatAddress" /></td>
                                <td rowspan="5">
                                    
                                </td>
                            </tr>
                            <tr>
                                <td>Gender:</td>
                                <td>
                                    <asp:Label runat="server" ID="OrderDetailPatGender" /></td>
                                <td></td>
                            </tr>
                            <tr>
                                <td>DOB:</td>
                                <td>
                                    <asp:Label runat="server" ID="OrderDetailPatDOB" /></td>
                                <td></td>
                            </tr>
                            <tr>
                                <td>Hospital number:</td>
                                <td>
                                    <asp:Label runat="server" ID="OrderDetailPatHospitalNo" /></td>
                            </tr>
                            <tr>
                                <td>NHS number:</td>
                                <td>
                                    <asp:Label runat="server" ID="OrderDetailPatNHSNo" /></td>
                                <td></td>
                            </tr>
                        </table>
                        <br />
                        <h3>Order Information</h3>
                        <table border="0" style="padding:0px 0px 0px 0px;">
                            <tr>
                                <td style="width:80px;">Order Number:
                                </td>
                                <td style="width:90px;">
                                    <asp:Label runat="server" ID="lblOrderNo"></asp:Label>
                                </td>
                                <td style="width:20px;">&nbsp;</td>
                                <td style="width:80px;"></td>
                                <td style="width:90px;"></td>
                            </tr>
                            <tr>
                                <td>Order Date:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblOrderDate"></asp:Label>
                                </td>
                                <td rowspan="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                <td>Date Raised:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblDateRaised"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Date Received:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblDateReceived"></asp:Label>
                                </td>
                                <td>Due Date:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblDueDate"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Order Source:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblOrderSource"></asp:Label>
                                </td>
                                <td>Location:</td>
                                <td>

                                </td>
                            </tr>
                            <tr>
                                <td>Ward:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblWard"></asp:Label>
                                </td>
                                <td>Bed:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblBed"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Referral Consultant:</td>
                                <td><asp:Label runat="server" ID="lblReferralConsultantName"></asp:Label></td>
                                <td>Ref Cons Speciality:</td>
                                <td><asp:Label runat="server" ID="lblReferralConsultantSpeciality"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>Referral Hospital:</td>
                                <td colspan="4"><asp:Label runat="server" ID="lblReferralHospitalName"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>Assigned Care Professional:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblAssignedCareProfessional"></asp:Label>
                                </td>
                                <td>&nbsp;</td>
                                <td>Priority:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblPriority"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>Procedure Type:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblProcedureType"></asp:Label>
                                </td>
                                <td>&nbsp;</td>
                                <td>Order Status:</td>
                                <td>
                                    <asp:Label runat="server" ID="lblOrderStatus"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Rejection Reason:</td>
                                <td colspan="4">
                                    <asp:Label runat="server" ID="lblRejectionReason"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>Rejection Comments: </td>
                                <td colspan="4">
                                    <asp:Label runat="server" ID="lblRejectionComments"></asp:Label>
                                </td>
                            </tr>
                            <tr><td colspan="5">&nbsp;</td></tr>
                            <tr>
                                <td>
                                    <h3>Clinical History:</h3>
                                </td>
                                <td colspan="4" style="vertical-align:top!important;">
                                    <%--<hr style="border:1px dashed;color:#808080;background-color:#ffffff;"/>--%>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <asp:Label runat="server" ID="lblClinicalHistory"></asp:Label>
                                </td>
                            </tr>
                            <tr><td colspan="5">&nbsp;</td></tr>
                            <tr>
                                <td colspan="2">
                                    <h3>Questions & &nbsp;Answers:</h3>
                                </td>
                                <td colspan="3" style="vertical-align:top!important;">
                                    <%--<hr style="border:1px dashed;color:#808080;background-color:#ffffff;"/>--%>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <asp:Repeater ID="rptQuestionsAnswers" runat="server">
                                        <HeaderTemplate>
                                            <table style="padding:10px;width:100%;" border="0">
                                                <tr><td></td></tr>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <b>Question : </b>
                                                    &nbsp;&nbsp;
                                                    <asp:Label ID="lblQuestion" runat="server" Text='<%#Eval("Question") %>'></asp:Label>
                                                    <br />&nbsp;<br />
                                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Answer: &nbsp;<%#Eval("Answer") %>
                                                    <br />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            </table>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </td>
                            </tr>
                            <tr><td colspan="5">&nbsp;</td></tr>
                            <tr>
                                <td colspan="2">
                                    <h3>Previous Procedures History:</h3>
                                </td>
                                <td colspan="3" style="vertical-align:top!important;">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5">
                                    <asp:Repeater ID="rptPrevHistory" runat="server">
                                        <HeaderTemplate>
                                            <table style="padding:10px;width:100%;" border="0">
                                                <tr><td></td></tr>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <tr>
                                                <td>                                                                
                                                    <%#Eval("ProcedureDate") %>
                                                </td>
                                                <td>
                                                    <%#Eval("ProcedureType") %>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            </table>
                                        </FooterTemplate>
                                    </asp:Repeater>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
