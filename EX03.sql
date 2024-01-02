use TREINO
CREATE TABLE Funcionarios (
    ID int identity(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    DepartamentoID INT,
    Salario DECIMAL(10, 2)
);
CREATE TABLE tb_log_func (
    ID int  PRIMARY KEY,
    Mudanca VARCHAR(100) NOT NULL,
);
create or alter procedure insere_funcionario @nome varchar(100), @departamentoID int, @salario decimal(10,2)
as 
begin
	insert into Funcionarios values (@nome,@departamentoID,@salario)
end 

EXEC insere_funcionario
    @Nome = 'João Silva',
    @DepartamentoID = 1,
    @Salario = 5000.00;

EXEC insere_funcionario
    @Nome = 'Anyone',
    @DepartamentoID = 23,
    @Salario = 3500.00;


select * from Funcionarios

create or alter procedure att_salario @id int, @novo_salario decimal (10,2)
as
begin
	update Funcionarios set Salario = @novo_salario where ID = @id
	insert into tb_log_func values (@id, 'Alteracao no salario')
end 

CREATE OR ALTER TRIGGER tg_verifica_salario 
ON Funcionarios 
AFTER UPDATE
AS
BEGIN
    DECLARE @antigo_salario DECIMAL(10,2);
    DECLARE @novo_salario DECIMAL(10,2);

    SELECT @novo_salario = i.Salario, @antigo_salario = d.Salario
    FROM inserted i
    JOIN deleted d ON i.ID = d.ID;

    IF (@novo_salario <> @antigo_salario)
    BEGIN
        IF (@novo_salario > @antigo_salario)
        BEGIN
            INSERT INTO tb_log_func (ID, Mudanca) 
            SELECT i.ID, 'Aumento de Salário' 
            FROM inserted i;
        END
    END
END

create or alter procedure promover_funcionario @ID int, @novo_salario decimal(10,2)
as 
begin
	if (@novo_salario >=6000.0)
		insert into tb_log_func values (@ID,'Promocao concedida')
	else
		insert into tb_log_func values (@ID,'Promocao NÃO concedida')
end

create or alter trigger tg_insere_novo_func on Funcionarios 
after insert 
as
begin
	declare @id_func int;

	select  @id_func = i.ID   from inserted i
	insert into tb_log_func values (@id_func,'insercao de novo funcionario')
end 