CREATE FUNCTION fnMelisaBrojURijeci(@Broj as decimal(18,2))

	RETURNS VARCHAR(1024)
	
AS 
BEGIN
    --razdvajanje cijelog od decimalnog dijela
	DECLARE @Broj1 bigint;
	SET @Broj1 = FLOOR(@Broj);
	DECLARE @Broj2 bigint;
	SET @Broj2 = (@Broj - FLOOR(@Broj))*100;
	
	--deklarisanje tabela za jedinice, desetice i stotice
	DECLARE @Ispod20 TABLE (ID int identity(1,1), Rijec varchar(32))
	DECLARE @Ispod100 TABLE (ID int identity(2,1), Rijec varchar(32))
	DECLARE @Ispod1000 TABLE (ID int identity(1,1), Rijec varchar(32)) 
	
	
	INSERT @Ispod20 (Rijec) VALUES
		('jedan'), ('dva'), ('tri'), ('Äetiri'), ('pet'), ('Å¡est'), ('sedam'), ('osam'),
		('devet'), ('deset'), ('jedanaest'), ('dvanaest'), ('trinaest'), ('Äetrnaest'), ('petnaest'),
		('Å¡esnaest'),('sedamnaest'), ('osamnaest'), ('devetnaest'), ('jedna'), ('dvije')
		
	INSERT @Ispod100 VALUES
		('dvadeset'), ('trideset'), ('Äetrdeset'), ('pedeset'), ('Å¡ezdeset'), ('sedamdeset'),
		('osamdeset'), ('devedeset')
	
	INSERT @Ispod1000 VALUES
		('sto'), ('dvjesto'), ('tristo'), ('Äetiristo'), ('petsto'), ('Å¡eststo'), ('sedamsto'),
		('osamsto'), ('devetsto')
		
DECLARE @Bosnian1 varchar(1024) =
	
	(
		SELECT case
		
			WHEN @Broj1 = 0 THEN '  ' 

			--BROJEVI IZMEDJU 1 I 19
			WHEN @Broj1 BETWEEN 1 AND 19 THEN
					CASE
						WHEN @Broj1 = 1  THEN (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedna') + ' konvertibilna marka '
						WHEN @Broj1 = 2  THEN (SELECT Rijec FROM @Ispod20 WHERE Rijec='dvije') + ' konvertibilne marke '
						WHEN @Broj1 = 3 OR @Broj1= 4 THEN (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1) + ' konvertibilne marke '
						ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj) + ' konvertibilnih maraka '
					END
				
				--BROJEVI IZMEDJU 2O I 99
			WHEN @Broj1 BETWEEN 20 AND 99 THEN
				CASE	
					WHEN @Broj1%10 = 0
						THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/10) + ' konvertibilnih maraka '
					ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/10)  + ' i ' + dbo.fnMelisaBrojURijeci(@Broj1%10)
				END

			--BROJEVI IZMEDJU 100 I 999
			WHEN @Broj1 BETWEEN 100 AND 999 THEN
				CASE
					WHEN @Broj1%100 = 0
						THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/100) + ' konvertibilnih maraka '
					ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/100) + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%100)
				END
					
			--BROJEVI IZMEDJU 1000 I 999999
			WHEN @Broj1 BETWEEN 1000 AND 999999 THEN
				CASE

					WHEN @Broj1/1000 = 1 THEN
						CASE
							WHEN @Broj1%100 = 0 THEN
								CASE 
									WHEN @Broj1%1000 = 0
										THEN 'hiljadu konvertibilnih maraka '
									ELSE 'hiljadu ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
								END
			
							ELSE 'hiljadu '+ dbo.fnMelisaBrojURijeci(@Broj1%1000)
						END

					WHEN @Broj1/1000 = 2  THEN
						CASE
							WHEN @Broj1%100 = 0 THEN
								CASE
									WHEN @Broj1%1000 = 0
										THEN 'dvije hiljade konvertibilnih maraka '
									ELSE 'dvije hiljade' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
								END
							ELSE 'dvije hiljade '+ dbo.fnMelisaBrojURijeci(@Broj1%1000)	
						END

					WHEN @Broj1/1000 = 3 OR @Broj1/1000 = 4 THEN --PROVJERA ZA 2XXX, 3XXX I 4XXX BROJEVE
						CASE
							WHEN @Broj1%100 = 0 THEN
								CASE
									WHEN @Broj1%1000 = 0
										THEN (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000) + ' hiljade konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000) + ' hiljade ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
								END
							ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000) + ' hiljade' + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)	
						END

					WHEN @Broj1/1000 BETWEEN 5 AND 19 THEN
						CASE
							WHEN @Broj1%100 = 0 THEN
								CASE
									WHEN @Broj1%1000 = 0
										THEN (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000) + ' hiljada konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
								END
							ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000) + ' hiljada'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
						END


					WHEN @Broj1/1000 BETWEEN 20 AND 99 THEN
							CASE
								WHEN (@Broj1/1000)%10 = 0 THEN
									CASE 
										WHEN @Broj1%100 = 0 THEN
											CASE
												WHEN @Broj1%1000 = 0
													THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' hiljada	konvertibilnih maraka '
												ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
											END
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' hiljada'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
									END
								----------------------------------------------------------------------------------------------------------------------------
								WHEN (@Broj1/1000)%10 = 1 THEN
									CASE
										WHEN @Broj1%100 = 0 THEN
											CASE 
												WHEN @Broj1%1000 = 0
													THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + 'jedna hiljada konvertibilnih maraka'
												ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + 'jedna hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
											END
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + 'jedna hiljada'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
									END
								----------------------------------------------------------------------------------------------------------------------------
								WHEN (@Broj1/1000)%10 = 2 THEN
									CASE
										WHEN @Broj1%100 = 0 THEN
											CASE
												WHEN @Broj1%1000 = 0
													THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + 'dvije hiljade konvertibilnih maraka '
												ELSE  (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + 'dvije hiljade' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
											END
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + 'dvije hiljade'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
									END
								----------------------------------------------------------------------------------------------------------------------------
								WHEN (@Broj1/1000)%10 = 3 OR (@Broj1/1000)%10 = 4 THEN
									CASE
										WHEN @Broj1%100 = 0 THEN
											CASE
												WHEN @Broj1%1000 = 0
													THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000%10) + ' hiljade konvertibilnih maraka '
												ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000%10) + ' hiljade ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
											END
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000%10) + ' hiljade'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
									END
								----------------------------------------------------------------------------------------------------------------------------
							    ELSE 
									CASE
										WHEN @Broj1%100 = 0 THEN
											CASE
												WHEN @Broj1%1000 = 0
													THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000%10) + ' hiljada konvertibilnih maraka '
												ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000%10) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
											END
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000%10) + ' hiljada'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
									END
							END

					--------------------------------------------------------------------------------------------------------------------------------------------
					WHEN @Broj1/1000 BETWEEN 100 AND 999 THEN
							CASE
								WHEN (@Broj1/1000)%100 BETWEEN 11 AND 19 THEN --dodatni uslov za 1x
									CASE
										WHEN  @Broj1%100 = 0 THEN
											CASE
												WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA  - XXX 000
													THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%100) + ' hiljada konvertibilnih maraka '
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%100) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
											END
										ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%100) + ' hiljada' + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
									END
								--------------------------------------------------------------------
								WHEN (@Broj1/1000)%10 = 1 THEN --PROVJERA ZA XX1 XXX
									CASE
										WHEN (@Broj1/1000)%100 BETWEEN 1 AND 19 THEN
											CASE 
												WHEN @Broj1%100 = 0 THEN
													CASE 
														WHEN  @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XX1 000
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + 'jedna hiljada konvertibilnih maraka '
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100)+ 'jedna hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END	
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100)+ 'jedna hiljada'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
											END
										WHEN (@Broj1/1000)%100 BETWEEN 20 AND 99 THEN
											CASE 
												WHEN @Broj1%100 = 0 THEN 
													CASE
														WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XX1 000
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) +' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ 'jedna hiljada konvertibilnih maraka'
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) +' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ 'jedna hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ 'jedna hiljada'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
											END
									END
								---------------------------------------------------------------------------------------------
								WHEN (@Broj1/1000)%10 = 2 THEN --PROVJERA ZA XX2 XXX
									CASE	
										WHEN (@Broj1/1000)%100 BETWEEN 1 AND 19 THEN
											CASE
												WHEN @Broj1%100 = 0 THEN
													CASE
														WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XX2 000
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100)+ 'dvije hiljade konvertibilnih maraka'
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100)+ 'dvije hiljade ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100)+ 'dvije hiljade'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
											END
										WHEN (@Broj1/1000)%100 BETWEEN 20 AND 99 THEN
											CASE
												WHEN @Broj1%100 = 0 THEN 
													CASE
														WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XX2 000
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ 'dvije hiljade konvertibilnih maraka '
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ 'dvije hiljade ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ 'dvije hiljade'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
											END
									END
								--------------------------------------------------------------------------------------------------
								WHEN (@Broj1/1000)%10 = 3 OR (@Broj1/1000)%10 = 4 THEN --PROVJERA ZA XX3 XXX I XX4 XXX
									CASE	
										WHEN (@Broj1/1000)%100 BETWEEN 1 AND 19  THEN
											CASE
												WHEN @Broj1%100 = 0 THEN
													CASE
														WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XX4 000 I XX3 000
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljade konvertibilnih maraka '
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljade ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljade'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
											END
										WHEN (@Broj1/1000)%100 BETWEEN 20 AND 99 THEN
											CASE
												WHEN @Broj1%100 = 0 THEN
													CASE
														WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XX4 000 I XX3 000
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljade konvertibilnih maraka '
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) +' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljade ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) +' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljade'+ ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)	
											END
									END
								---------------------------------------------------------------------------------------------------------------------
								ELSE --PROVJERA ZA XXX XXX - BILO KOJI FORMAT 
									CASE	
										
										WHEN (@Broj1/1000)%100 = 10 THEN
											CASE 
												WHEN @Broj1%100 = 0 THEN
													CASE
														WHEN @Broj1%1000 = 0
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Deset') + ' hiljada konvertibilnih maraka '
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Deset') + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END 
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Deset') + ' hiljada' + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000) 
											END
										WHEN (@Broj1/1000)%100 BETWEEN 5 AND 19 THEN --ZA FORMATE X0X XXX ILI X1X XXX
											CASE
												WHEN @Broj1%100 = 0 THEN --ZA FORMATE X0X X00 ILI X1X X00
													CASE
														WHEN @Broj1%1000 = 0 -- ZA BROJEVE FORMATA - XXX 000 
															THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljada konvertibilnih maraka '
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
													END
												ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljada' + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)
											END
										--------------------------------------------------------------------
										WHEN (@Broj1/1000)%100 BETWEEN 20 AND 99 THEN
											CASE 
												WHEN ((@Broj1/1000)%100)%10 = 0 THEN --ZA BROJEVE FORMATA XX0 XXX --OVO DODAT U DIO IZNAD MOZDA ??
													CASE
														WHEN @Broj1%100 = 0 THEN
															CASE 
																WHEN @Broj1%1000 = 0 
																	THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10) + ' hiljada konvertibilnih maraka '
																ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
															END
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10) + ' hiljada' + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)	
													END
												ELSE 
													CASE
														WHEN @Broj1%100 = 0 THEN
															CASE 
																WHEN @Broj1%1000 = 0
																	THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljada konvertibilnih maraka '
																ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljada ' + (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1%1000/100) + ' konvertibilnih maraka '
															END
														ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000%100)/10)+ ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000)%10) + ' hiljada' + ' ' + dbo.fnMelisaBrojURijeci(@Broj1%1000)	
													END
											END
									END
							END
				END
				
			--BROJEVI IZMEDJU 1000000 I 999999999
			WHEN @Broj1 BETWEEN 1000000 AND 999999999 THEN
				CASE
					WHEN (@Broj1/1000000) = 1 THEN --PROVJERA ZA milionE - 1 XXX XXX
						CASE
							WHEN @Broj1%1000000 = 0 --provjera za format 1 000 000
								THEN (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' milion konvertibilnih maraka'
							ELSE (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' milion ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
						END

					WHEN (@Broj1/1000000) BETWEEN 2 AND 19 THEN 
						CASE
							WHEN @Broj1%1000000 = 0
								THEN (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000) + ' miliona konvertibilnih maraka' 
								ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000) + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
						END

					WHEN (@Broj1/1000000) BETWEEN 20 AND 99 THEN
						CASE	
							WHEN (@Broj1/1000000)%10 = 0 THEN
								CASE
									WHEN @Broj1%1000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000/10) + ' miliona konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000/10) + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
								END
							WHEN (@Broj1/1000000)%10 = 1 THEN 
								CASE
									WHEN  @Broj1%1000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000/10) + ' jedan milion konvertibilnih maraka'
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000/10) + ' jedan milion ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
								END
							ELSE 
								CASE
									WHEN @Broj1%1000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000%10)+ ' miliona konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000%10)+ ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
								END
						END
				

					WHEN (@Broj1/1000000) BETWEEN 100 AND 999 THEN
						CASE 

							WHEN (@Broj1/1000000)%100 = 0 THEN --RADI za X00 miliona
								CASE
									WHEN @Broj1%1000000 = 0
										THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' miliona konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
								END
							WHEN (@Broj1/1000000)%10 = 0 THEN  --RADI za XX0 miliona
								CASE 
									WHEN (@Broj1/1000000)%100 = 10 THEN --RADI ZA X10 milijardi
										CASE
											WHEN @Broj1%1000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' deset miliona konvertibilnih maraka' 
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' deset miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
										END

									ELSE
										CASE
											WHEN @Broj1%1000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000%100)/10) + ' miliona konvertibilnih maraka' 
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000%100)/10) + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
										END
								END

							WHEN (@Broj1/1000000)%100 BETWEEN 1 AND 19 THEN --RADI 
								CASE
									WHEN (@Broj1/1000000)%100 = 1 THEN--USLOV ZA X01 miliona
										CASE
											WHEN @Broj1%1000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' milion konvertibilnih maraka'
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' milion ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
										END
										
									WHEN (@Broj1/1000000)%100 = 11 THEN--uslov za x11 miliona
										CASE
											WHEN @Broj1%1000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedanaest') + ' miliona konvertibilnih maraka'
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedanaest') + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
										END
									ELSE	
										CASE
											WHEN @Broj1%1000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000)%100) + ' miliona konvertibilnih maraka'
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000)%100) + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
										END
								END
							WHEN (@Broj1/1000000)%100 BETWEEN 20 AND 99 THEN --RADI
								CASE
									WHEN @Broj1%1000000 = 0
										THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000%100)/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000%100)%10) + ' miliona konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000%100)/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000%100)%10) + ' miliona ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000)
								END
						END	
				END
--------------------------------------------DIO ZA milijarde------------------------------------------------------------------------------
			--BROJEVI IZMEDJU 1000000000 I 999999999999
			WHEN @Broj1 BETWEEN 1000000000 AND 999999999999 THEN
				CASE
					WHEN (@Broj1/1000000000) = 1 THEN --PROVJERA ZA milionE - 1 XXX XXX
						CASE
							WHEN @Broj1%1000000000 = 0 --provjera za format 1 000 000 000
								THEN (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedna') + ' milijarda konvertibilnih maraka'
							ELSE (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedna') + ' milijarda ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
						END
					
					WHEN (@Broj1/1000000000) = 2 THEN
						CASE
							WHEN @Broj1%1000000000 = 0
								THEN (SELECT Rijec FROM @Ispod20 WHERE Rijec='dvije') + ' milijarde konvertibilnih maraka' 
							ELSE (SELECT Rijec FROM @Ispod20 WHERE Rijec='dvije') + ' milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
						END
					
					WHEN (@Broj1/1000000000) = 3 OR (@Broj1/1000000000) = 4 THEN
						CASE
							WHEN @Broj1%1000000000 = 0
								THEN (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000) + ' milijarde konvertibilnih maraka' 
							ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000) + ' milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
						END 
					
					WHEN (@Broj1/1000000000) BETWEEN 5 AND 19 THEN 
						CASE
							WHEN @Broj1%1000000000 = 0
								THEN (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000) + ' milijardi konvertibilnih maraka' 
							ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000) + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
						END

					WHEN (@Broj1/1000000000) BETWEEN 20 AND 99 THEN
						CASE	
							WHEN (@Broj1/1000000000)%10 = 0 THEN --za format x0 xxx xxx 
								CASE
									WHEN @Broj1%1000000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' milijardi konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
								END
							WHEN (@Broj1/1000000000)%10 = 1 THEN --za format x1 xxx xxx
								CASE
									WHEN  @Broj1%1000000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' jedna milijarda konvertibilnih maraka'
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' jedna milijarda ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
								END
							
							WHEN (@Broj1/1000000000)%10 = 2 THEN --za format x2 xxx xxx
								CASE
									WHEN  @Broj1%1000000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' dvije milijarde konvertibilnih maraka'
										ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' dvije milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
								END
							
							WHEN (@Broj1/1000000000)%10 = 3 OR (@Broj1/1000000000)%10 = 4 THEN
								CASE
									WHEN @Broj1%1000000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000%10)+ ' milijarde konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000%10)+ ' milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
								END
							
							ELSE 
								CASE
									WHEN @Broj1%1000000000 = 0
										THEN (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000%10)+ ' milijardi konvertibilnih maraka'
									ELSE (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj1/1000000000/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj1/1000000000%10)+ ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
								END
						END
				

					WHEN (@Broj1/1000000000) BETWEEN 100 AND 999 THEN
						CASE 

							WHEN (@Broj1/1000000000)%100 = 0 THEN --RADI za X00 miliona
								CASE
									WHEN @Broj1%1000000000 = 0
										THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' milijardi konvertibilnih maraka '
									ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
								END
							WHEN (@Broj1/1000000000)%10 = 0 THEN  --RADI za XX0 miliona
								CASE 
									WHEN (@Broj1/1000000000)%100 = 10 THEN --RADI ZA X10 milijardi
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' deset milijardi konvertibilnih maraka ' 
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + 'deset milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
									ELSE
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' milijardi konvertibilnih maraka ' 
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
								END

							WHEN (@Broj1/1000000000)%100 BETWEEN 1 AND 19 THEN --RADI 
								CASE
									WHEN (@Broj1/1000000000)%100 = 1 THEN--USLOV ZA X01 miliona
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedna') + ' milijarda konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedna') + ' milijarda ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
										
									WHEN (@Broj1/1000000000)%100 = 2 THEN--USLOV ZA X02 miliona
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='dvije') + ' milijarde konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='dvije') + ' milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END

									WHEN (@Broj1/1000000000)%100 = 3 OR (@Broj1/1000000000)%100 = 4 THEN
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000)%100) + ' milijarde konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000)%100) + ' milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END

									WHEN (@Broj1/1000000000)%100 = 11 THEN--uslov za x11 miliona
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedanaest') + ' milijardi konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedanaest') + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
									ELSE	
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100)  + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000)%100) + ' milijardi konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000)%100) + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
								END
							WHEN (@Broj1/1000000000)%100 BETWEEN 20 AND 99 THEN --RADI
								CASE
									WHEN (@Broj1/1000000000)%10 = 1 THEN --za format xx1 milijarda
										CASE 
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' jedna milijarda konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10)+ ' jedna milijarda ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
									
									WHEN (@Broj1/1000000000)%10 = 2 THEN --za format xx2 milijarde
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' dvije milijarde konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' dvije milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
									
									WHEN (@Broj1/1000000000)%10 = 3 OR (@Broj1/1000000000)%10 = 4 THEN --za format xx3 ILI xx4 milijarde 
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000%100)%10) + ' milijarde konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000%100)%10) + ' milijarde ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
									
									ELSE
										CASE
											WHEN @Broj1%1000000000 = 0
												THEN (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000%100)%10) + ' milijardi konvertibilnih maraka '
											ELSE (SELECT Rijec FROM @Ispod1000 WHERE ID=@Broj1/1000000000/100) + ' ' + (SELECT Rijec FROM @Ispod100 WHERE ID=(@Broj1/1000000000%100)/10) + ' ' + (SELECT Rijec FROM @Ispod20 WHERE ID=(@Broj1/1000000000%100)%10) + ' milijardi ' + dbo.fnMelisaBrojURijeci(@Broj1%1000000000)
										END
								END
						END	
				END
				
			ELSE 'Greska' END
)
----------------------------------------------------------------------------------------------------------------------------------

	DECLARE @Bosnian2 varchar(1024) =
	(
		SELECT case
		
		WHEN @Bosnian1 = ' ' THEN
			CASE
				WHEN @Broj2 = 0 THEN ' '

			--BROJEVI IZMEDJU 1 I 19
		
				WHEN @Broj2 BETWEEN 1 AND 19 THEN
					CASE
						WHEN @Broj2 = 1  THEN (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' fening'
						ELSE (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj2) + ' feninga' 
					END
				
			--BROJEVI IZMEDJU 2O I 99
				WHEN @Broj2 BETWEEN 20 AND 99 THEN
					CASE
					
						WHEN @Broj2%10 = 0 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' feninga'
						WHEN @Broj2%10 = 1 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' +  (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' fening'
						WHEN @Broj2%10 = 2 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='dva') + ' feninga'
						WHEN @Broj2%10 = 3 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='tri') + ' feninga'
						WHEN @Broj2%10 = 4 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Äetiri') + ' feninga'
						WHEN @Broj2%10 = 5 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='pet') + ' feninga'
						WHEN @Broj2%10 = 6 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Å¡est') + ' feninga'
						WHEN @Broj2%10 = 7 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='sedam') + ' feninga'
						WHEN @Broj2%10 = 8 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='osam') + ' feninga'
						WHEN @Broj2%10 = 9 THEN 
						(SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='devet') + ' feninga'
						ELSE 'POGRESAN UNOS'
					END
			
			END
		
		ELSE 
			CASE
			
				WHEN @Broj2 = 0 THEN ' '

				--BROJEVI IZMEDJU 1 I 19
		
				WHEN @Broj2 BETWEEN 1 AND 19 THEN
					CASE
						WHEN @Broj2 = 1  THEN 'i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' fening'
						ELSE 'i ' + (SELECT Rijec FROM @Ispod20 WHERE ID=@Broj2) + ' feninga' 
					END
				
				--BROJEVI IZMEDJU 2O I 99
				WHEN @Broj2 BETWEEN 20 AND 99 THEN
					CASE
					
						WHEN @Broj2%10 = 0 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' feninga'
						WHEN @Broj2%10 = 1 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='jedan') + ' fening'
						WHEN @Broj2%10 = 2 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='dva') + ' feninga'
						WHEN @Broj2%10 = 3 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='tri') + ' feninga'
						WHEN @Broj2%10 = 4 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Äetiri') + ' feninga'
						WHEN @Broj2%10 = 5 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='pet') + ' feninga'
						WHEN @Broj2%10 = 6 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='Å¡est') + ' feninga'
						WHEN @Broj2%10 = 7 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='sedam') + ' feninga'
						WHEN @Broj2%10 = 8 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='osam') + ' feninga'
						WHEN @Broj2%10 = 9 THEN 
						'i ' + (SELECT Rijec FROM @Ispod100 WHERE ID=@Broj2/10) + ' i ' + (SELECT Rijec FROM @Ispod20 WHERE Rijec='devet') + ' feninga'
						ELSE 'POGRESAN UNOS'
					END
			END
		END
	)				

	DECLARE @Bosnian varchar(1024) = 
		(
			SELECT CASE
				WHEN @Bosnian1 = ' 'THEN @Bosnian2
				ELSE @Bosnian1 + @Bosnian2
			END
		)
	RETURN UPPER(LEFT(@Bosnian,1))+LOWER(SUBSTRING(@Bosnian,2,LEN(@Bosnian))) --POCETNO SLOVO STRINGA UPPERCASE

	END
---------------------------------------------------------------------------------------------------------------------------------
GO 


--SELECT BrojNaBosanskom = dbo.fnMelisaBrojURijeci(158795) 
SELECT BrojNaBosanskom = dbo.fnMelisaBrojURijeci(158795.88) 


                