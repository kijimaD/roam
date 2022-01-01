class Store
  attr_reader :results

  def initialize(bases)
    @results = bases
  end

  def merge(tos)
    @results.each do |k, v|
      @results.store(k, v.merge(tos[k]))
    end

    self
  end
end
