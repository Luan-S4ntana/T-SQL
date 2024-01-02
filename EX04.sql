-- Tabela Autores
CREATE TABLE Autores (
    AutorID INT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Nascimento DATE,
    Nacionalidade VARCHAR(50)
);

-- Tabela Livros
CREATE TABLE Livros (
    LivroID INT identity(1,1) PRIMARY KEY,
    Titulo VARCHAR(100) NOT NULL,
    AutorID INT,
    AnoPublicacao INT,
    Genero VARCHAR(50)
);

-- Chave estrangeira referenciando AutorID na tabela Livros
ALTER TABLE Livros
ADD FOREIGN KEY (AutorID) REFERENCES Autores(AutorID);

create or alter procedure insereLivros  @titulo varchar(100),
										@autorID int,
										@anopublicacao int,
										@genero varchar(50)
as
begin						
	if exists (select * from Autores where AutorID = @autorID)
		begin
			insert into Livros (Titulo, AutorID, AnoPublicacao, Genero)
			values (@titulo, @autorID, @anopublicacao, @genero);
		end
	else
		PRINT 'Autor inexistente';
end

create or alter trigger tg_verifica_ano_publicacao on Livros 
after insert, update 
as 
begin
	declare @anopubli int,
			@nascimento int 
	select @anopubli = i.AnoPublicacao, @nascimento = YEAR(a.Nascimento) from inserted i inner join Autores A ON i.AutorID = a.AutorID where i.AutorID = a.AutorID
		begin
			if (@nascimento >= @anopubli)
				print 'ErrosLivros'
		end
end
