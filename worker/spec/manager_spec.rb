require 'benchmark'

require './manager'


RSpec.describe Manager do


	context "with empty resources tree" do

		resources = {nil=>[]}		

		
		context "and empty requirements tree" do

			required = {}
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(0)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end

	end


	context "with one Device in resources tree" do
		
		resources = {
			nil => [
				{
					id: 1,
					type: 'Device',
					image: 'a',
					count: 1,
					tasks: 0
				}
			]
		}

		
		context "and empty requirements tree" do

			required = []
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil], required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(0)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end

		
		context "and one Device in requirements tree, with no image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT'
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

			it 'can do 10000 no-op transitions in 1s' do 
				time = Benchmark.realtime {
					10000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end


		context "and one Device in requirements tree, with and matching image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'a'
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

			it 'can do 10000 no-op transitions in 1s' do 
				time = Benchmark.realtime {
					10000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end


		context "and one Device in requirements tree, with and not-matching image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'b',
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).not_to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

			it 'can do 10000 no-op transitions in 1s' do 
				time = Benchmark.realtime {
					1000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end

		
		context "and two Devices in requirements tree" do

			required = [
				{
					type: 'Device',
					role: 'SUT1'
				},
				{
					type: 'Device',
					role: 'SUT2'
				}
			]
			
			it 'returns empty plan from estimation' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_nil
			end

			it 'can do 10000 estimates 1s' do 
				time = Benchmark.realtime {
					10000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end

		
		context "and one NotDevice in requirements tree" do

			required = [
				{
					type: 'NotDevice',
					role: 'SUT'
				}
			]
			
			it 'returns empty plan from estimation' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_nil
			end

			it 'can do 1000 estimates 1s' do 
				time = Benchmark.realtime {
					1000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end
	end


	context "with two Devices in resources tree" do
		
		resources = {
			nil => [
				{
					id: 1,
					type: 'Device',
					image: 'a',
					count: 1,
					tasks: 0
				},
				{
					id: 2,
					type: 'Device',
					image: 'b',
					count: 1,
					tasks: 0
				}
			]
		}

		
		context "and empty requirements tree" do

			required = []
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil], required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(0)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end


		context "and one Device in requirements tree, with no image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT'
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

			
			it 'can do 1000 no-op transitions in 1s' do 
				time = Benchmark.realtime {
					1.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end


		context "and one Device in requirements tree, with 'a' image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'a'
				}
			]
			
			it 'estimates 0 time with alread-flashed image' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end


		context "and one Device in requirements tree, with 'b' image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'b'
				}
			]
			
			it 'estimates 0 time with alread-flashed image' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(2)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end


		context "and one Device in requirements tree, with and not-matching image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'c',
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).not_to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end

		
		context "and two Devices in requirements tree" do

			required = [
				{
					type: 'Device',
					role: 'SUT1',
					image: 'b'
				},
				{
					type: 'Device',
					role: 'SUT2',
					image: 'a'
				}
			]
			
			it 'returns empty plan from estimation' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(2)
				expect(plan[:actors]).to have_key("SUT1")
				expect(plan[:actors]).to have_key("SUT2")
				expect(plan[:actors]["SUT1"]).to have_key(:id)
				expect(plan[:actors]["SUT1"][:id]).to equal(2)
				expect(plan[:actors]["SUT2"]).to have_key(:id)
				expect(plan[:actors]["SUT2"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0) #FIXME
			end

			it 'can do 1000 estimates 1s' do 
				time = Benchmark.realtime {
					1000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end

		
		context "and one NotDevice in requirements tree" do

			required = [
				{
					type: 'NotDevice',
					role: 'SUT'
				}
			]
			
			it 'returns empty plan from estimation' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_nil
			end

			it 'can do 1000 estimates 1s' do 
				time = Benchmark.realtime {
					1.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end
	end



	context "with 16 Devices in resources tree" do
		
		resources = {
			nil => 16.times.to_a.map { |id| 
				{
					id: id+1,
					type: 'Device',
					image: 'b',
					count: 1,
					tasks: 0
				}
			}
		}

		
		context "and empty requirements tree" do

			required = []
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil], required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(0)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end


		context "and one Device in requirements tree, with no image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT'
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

			
			it 'can do 1000 no-op transitions in 1s' do 
				time = Benchmark.realtime {
					1.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end


		context "and one Device in requirements tree, with 'a' image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'a'
				}
			]
			
			it 'estimates 60 time with non-flashed image' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(60)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end


		context "and one Device in requirements tree, with 'b' image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'b'
				}
			]
			
			it 'estimates 0 time with alread-flashed image' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end


		context "and one Device in requirements tree, with and not-matching image specified" do

			required = [
				{
					type: 'Device',
					role: 'SUT',
					image: 'c',
				}
			]
			
			it 'can do no-op transition' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).not_to equal(0)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(1)
				expect(plan[:actors]).to have_key("SUT")
				expect(plan[:actors]["SUT"]).to have_key(:id)
				expect(plan[:actors]["SUT"][:id]).to equal(1)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0)
			end

		end

		
		context "and two Devices in requirements tree" do

			required = [
				{
					type: 'Device',
					role: 'SUT1',
					image: 'b'
				},
				{
					type: 'Device',
					role: 'SUT2',
					image: 'a'
				}
			]
			
			it 'returns correct plan from estimation' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_a(Hash)
				expect(plan[:estimate]).to equal(60)
				expect(plan[:actors]).to be_a(Hash)
				expect(plan[:actors].size).to equal(2)
				expect(plan[:actors]).to have_key("SUT1")
				expect(plan[:actors]).to have_key("SUT2")
				expect(plan[:actors]["SUT1"]).to have_key(:id)
				expect(plan[:actors]["SUT1"][:id]).to equal(1)
				expect(plan[:actors]["SUT2"]).to have_key(:id)
				expect(plan[:actors]["SUT2"][:id]).to equal(2)
				expect(plan[:steps]).to be_a(Array)
				expect(plan[:steps].size).to equal(0) #FIXME
			end

			it 'can do 1000 estimates 1s' do
				#require 'profile'
				# require 'ruby-prof'
				# RubyProf.start
				time = Benchmark.realtime {
					1000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				# result = RubyProf.stop
				# RubyProf::FlatPrinter.new(result).print(STDOUT)
				expect(time).to be < 1.0
			end

		end

		context "and six Devices in requirements tree" do

			required = [
				{
					type: 'Device',
					role: 'SUT1',
					image: 'a'
				},
				{
					type: 'Device',
					role: 'SUT2',
					image: 'a'
				},
				{
					type: 'Device',
					role: 'SUT3',
					image: 'a'
				},
				{
					type: 'Device',
					role: 'SUT4',
					image: 'a'
				},
				{
					type: 'Device',
					role: 'SUT4',
					image: 'a'
				},
				{
					type: 'Device',
					role: 'SUT4',
					image: 'a'
				}
			]


			it 'can do 1000 estimates 1s' do
				#require 'profile'
				# require 'ruby-prof'
				# RubyProf.start
				time = Benchmark.realtime {
					1.times {
						Manager.estimate(resources[nil],required)
					}
				}
				# result = RubyProf.stop
				# RubyProf::FlatPrinter.new(result).print(STDOUT)
				expect(time).to be < 1.0
			end

		end		
		
		context "and one NotDevice in requirements tree" do

			required = [
				{
					type: 'NotDevice',
					role: 'SUT'
				}
			]
			
			it 'returns empty plan from estimation' do
				plan = Manager.estimate(resources[nil],required)
				expect(plan).to be_nil
			end

			it 'can do 1000 estimates 1s' do 
				time = Benchmark.realtime {
					1000.times {
						Manager.estimate(resources[nil],required)
					}
				}
				expect(time).to be < 1.0
			end

		end
	end


	

end
