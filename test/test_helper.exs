ExUnit.start()

File.ls!("./test/support")
|> Enum.each(&(Code.require_file("support/#{&1}", __DIR__)))
