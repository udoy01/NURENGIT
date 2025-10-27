SUBROUTINE GB.E.NOF.PO.PS.SDR.OUTSTANDING(Y.RETURN)
*=================================================================================================================================
* Developed by       : Nuren Durdana Abha (FDS)
* Description        : Shows data of OUTSTANDING PO PS SDR from CHEQUE.REGISTER.SUPPLEMENT application
* RTN Attached in    : APPLICATION: ENQUIRY, ID: GB.ENQ.PO.PS.SDR.OUTSTANDING
* Routine Type       : Enquiry
* Standard Selection : NOFILE.PO.PS.SDR.OUTSTANDING
* Compilation Time   : 05 Jan, 2025 (21:06)
*=================================================================================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING FT.Contract
    $USING TT.Contract
    $USING EB.LocalReferences
            
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB MAIN
RETURN
    
INIT:
    FN.CHQ= 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHQ= ''
    
    FN.FT= 'F.FUNDS.TRANSFER'
    F.FT= ''
    
    FN.TT= 'F.TELLER'
    F.TT= ''
    
    FN.FT.NAU= 'F.FUNDS.TRANSFER$NAU'
    F.FT.NAU= ''
    
    FN.TT.NAU= 'F.TELLER$NAU'
    F.TT.NAU= ''
    
    Y.ID.NO= ''
    Y.PAY.TO= ''
    Y.ISS.AMT= 0
    Y.ISS.DT= ''
    Y.REFERENCE= ''
    Y.PO.PS.SDR= ''
    Y.ORIGIN= ''
    Y.ORIGIN.REF= ''
    Y.STATUS= ''
    Y.COLL.TXN.REF= ''
RETURN
    
OPENFILE:
    EB.DataAccess.Opf(FN.CHQ,F.CHQ)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.FT.NAU,F.FT.NAU)
    EB.DataAccess.Opf(FN.TT.NAU,F.TT.NAU)
RETURN

MAIN:
    EB.LocalReferences.GetLocRef('FUNDS.TRANSFER','LT.BD.PO.TYPE', Y.PO.TYPE.POS)
    EB.LocalReferences.GetLocRef('TELLER','LT.BD.PO.TYPE', Y.TT.PO.TYPE.POS)
    EB.LocalReferences.GetLocRef('CHEQUE.REGISTER.SUPPLEMENT','LT.COLL.TXN.REF', Y.COLL.TXN.REF.POS)
    
    SEL.CMD= 'SELECT ':FN.CHQ:' STATUS EQ ISSUED CLEARED STOPPED AND ID.COMP1 EQ PO PS SDR AND CO.CODE EQ ': EB.SystemTables.getIdCompany()
    
    EB.DataAccess.Readlist(SEL.CMD, SELECT.LIST, '', NO.OF.ITEM, RET.CODE)
    SELECT.LIST.SORTED= SORT(SELECT.LIST)
    
    LOOP
        REMOVE TRN.ID FROM SELECT.LIST.SORTED SETTING TXN.POS
    WHILE TRN.ID:TXN.POS
    
        Y.CHQ.ID= TRN.ID
        EB.DataAccess.FRead(FN.CHQ,Y.CHQ.ID,CHQ.REC,F.CHQ,Y.ERR)
        IF CHQ.REC THEN
            Y.ORIGIN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsOriginRef>
            Y.STATUS= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus>
            Y.COLL.TXN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef,Y.COLL.TXN.REF.POS>
        END

*Checking for FT TT INAU records for cleared=========================================================================
        IF Y.STATUS EQ 'CLEARED' THEN
            IF Y.COLL.TXN.REF THEN
                IF Y.COLL.TXN.REF[1,2] EQ 'FT' THEN
                    EB.DataAccess.FRead(FN.FT.NAU,Y.COLL.TXN.REF,FT.REC,F.FT.NAU,FT.ERR)
                    IF FT.REC THEN
                        GOSUB DATA.FETCH
                    END
                END
                ELSE IF Y.COLL.TXN.REF[1,2] EQ 'TT' THEN
                    EB.DataAccess.FRead(FN.TT.NAU,Y.COLL.TXN.REF,TT.REC,F.TT.NAU,TT.ERR)
                    IF TT.REC THEN
                        GOSUB DATA.FETCH
                    END
                END
            END
        END
*Checking for FT TT INAU records for issued=========================================================================
        ELSE IF Y.STATUS EQ 'ISSUED' THEN
            IF Y.ORIGIN.REF THEN
                IF Y.ORIGIN.REF[1,2] EQ 'FT' THEN
                    EB.DataAccess.FRead(FN.FT.NAU,Y.ORIGIN.REF,FT.REC,F.FT.NAU,FT.ERR)
                    IF FT.REC EQ '' THEN
                        GOSUB DATA.FETCH
                    END
                END
                ELSE IF Y.ORIGIN.REF[1,2] EQ 'TT' THEN
                    EB.DataAccess.FRead(FN.TT.NAU,Y.ORIGIN.REF,TT.REC,F.TT.NAU,TT.ERR)
                    IF TT.REC EQ '' THEN
                        GOSUB DATA.FETCH
                    END
                END
            END
            ELSE
                GOSUB DATA.FETCH   ;*For Migrated CRS
            END
        END
*No checking for stopped=========================================================================
        ELSE
            GOSUB DATA.FETCH
        END
    
    REPEAT
RETURN

DATA.FETCH:
    EB.DataAccess.FRead(FN.CHQ,Y.CHQ.ID,CHQ.REC,F.CHQ,Y.ERR)
    IF CHQ.REC THEN
        Y.ID.NO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompThr>
        Y.PAY.TO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
        Y.ISS.AMT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
        Y.ISS.DT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIssueDate>
        Y.PO.PS.SDR= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompOne>
    END
    
    IF Y.ORIGIN.REF[1,2] EQ 'FT' THEN
        Y.PO.PUR= ''
        EB.DataAccess.FRead(FN.FT,Y.ORIGIN.REF,FT.REC,F.FT,FT.ERR)
        IF FT.REC THEN
            Y.PO.PUR= FT.REC<FT.Contract.FundsTransfer.LocalRef,Y.PO.TYPE.POS>
        END
    END
    
    IF Y.ORIGIN.REF[1,2] EQ 'TT' THEN
        Y.PO.PUR= ''
        EB.DataAccess.FRead(FN.TT,Y.ORIGIN.REF,TT.REC,F.TT,TT.ERR)
        IF TT.REC THEN
            Y.PO.PUR= TT.REC<TT.Contract.Teller.TeLocalRef,Y.TT.PO.TYPE.POS>
        END
    END
    
    Y.RETURN<-1>= Y.ID.NO:'*':Y.ISS.DT:'*':Y.PAY.TO:'*':Y.ISS.AMT:'*':Y.ORIGIN.REF:'*':Y.PO.PUR:'*':Y.ORIGIN.REF:'*':Y.PO.PS.SDR
    !---------------*1*---------*2*-----------*3*----------*4*-----------*5*-------------*6*-----------*7*--------------*8*
    
RETURN

END

