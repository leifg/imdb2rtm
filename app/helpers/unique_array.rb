class UniqueArray < Array
  def initialize(*args)
    if args.size == 1 and args[0].is_a? Array then
      super(args[0].uniq)
    else
      super(*args)
    end
  end

  def insert(i, v)
    super(i, v) unless include?(v)
  end

  def <<(v)
    super(v) unless include?(v)
  end

  def []=(*args)
    # note: could just call super(*args) then uniq!, but this is faster

    # there are three different versions of this call:
    # 1. start, length, value
    # 2. index, value
    # 3. range, value
    # We just need to get the value
    v = case args.size
      when 3 then args[2]
      when 2 then args[1]
      else nil
    end

    super(*args) if v.nil? or not include?(v)
  end
end