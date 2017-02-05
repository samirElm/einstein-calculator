module Commands
  class Responder
    def respond(result)
      responses_for(result).sample
    end

    private

    def responses_for(result)
      [
        "Ça fait *#{result}* ! C'est la dernière fois que tu me déranges pour un calcul aussi bidon :rage: ",
        "T'es sérieux là ? Je te fais ça de tête... *#{result}* !",
        "Ah, enfin un calcul compliqué... Nan je déconne :joy:... ça fait *#{result}* !",
        "Voilà ton résultat : *#{result}*. Tu devais pas être assis au 1er rang toi..",
        "Ouah.. Tu me déranges pour un calcul aussi flingué... Ça fait *#{result}* imbécile !",
        "*#{result}* ! Et me prends plus la tête avec tes calculs bidons :rage:",
        "Voilà ton résultat : *#{result}*. T'es content ?",
        "Tu me rends fou avec tes questions. Ça fait *#{result}* !"
      ]
    end
  end
end
