module BrawoCms
  module RecordFinder
    module_function

    def find(scope, key)
      if key.to_s.match?(/\A\d+\z/)
        scope.find_by(id: key)
      else
        scope.find_by(slug: key)
      end
    end
  end
end
