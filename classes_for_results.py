# draft of class(es) for recording measurement results
# following example from MIT 6.002x problem set 4

# desired output format
# 0 filename, 1-3 c1 whole image (mean, intden, rawintden), 
# 4 c1 nuclei count, average and sd of c1 (5-6 area, 7-8 mean, 9-10 intden, 11-12 rawintden), 
# 13 c2 nuclei count, average and sd of c2 (14-15 area, 16-17 mean, 18-19 intden, 20-21 rawintden)

class ImageResults(object):
    """
    A collection of measurements on an image
    """
    def __init__(self, C1results, C2results, imagename):
        """
        Initialize an ImageResults instance, which stores the temperature records
        loaded from a previously read csv file specified by results.

        Args:
            imagename: name of the image to be queried
        """
# the only attribute of this class is rawdata
# it is a massive... dictionary? table?

# look through the csv and pull out all the info pertaining to this image

        self.rawdata = {}

        f = open(filename, 'r')
        header = f.readline().strip().split(',') # first line -- what does strip do?
        for line in f: # after the header since it has already been read
            items = line.strip().split(',') 

# what is happening here?
# does it require numpy?

            city = items[header.index('CITY')] 
            temperature = float(items[header.index('TEMP')])
            if city not in self.rawdata:
                self.rawdata[city] = {}
            if year not in self.rawdata[city]:
                self.rawdata[city][year] = {}
            if month not in self.rawdata[city][year]:
                self.rawdata[city][year][month] = {}
            self.rawdata[city][year][month][day] = temperature
            
        f.close()

# adapt this to get:
# subclasses: channel, channelplus (one has an extra attribute, the whole image info)
# lines for all nuclei in a channel -- channel.getNuclei
# lines for the whole channel data if available (mean, ID, RID) -- channelplus.getWholeImageData
# lists of values for nuclei per channel: area, mean, ID, RID  -- channel.getNucleiData
# you could make a nucleus an additional object but it may not be worth it
# send the info back to the main program which will calculate the means and sds

    def get_yearly_temp(self, city, year):
        """
        Get the daily temperatures for the given year and city.

        Args:
            city: city name (str)
            year: the year to get the data for (int)

        Returns:
            a numpy 1-d array of daily temperatures for the specified year and
            city
        """
        temperatures = []
        assert city in self.rawdata, "provided city is not available"
        assert year in self.rawdata[city], "provided year is not available"
        for month in range(1, 13):
            for day in range(1, 32):
                if day in self.rawdata[city][year][month]:
                    temperatures.append(self.rawdata[city][year][month][day])
        return np.array(temperatures)

    def get_daily_temp(self, city, month, day, year):
        """
        Get the daily temperature for the given city and time (year + date).

        Args:
            city: city name (str)
            month: the month to get the data for (int, where January = 1,
                December = 12)
            day: the day to get the data for (int, where 1st day of month = 1)
            year: the year to get the data for (int)

        Returns:
            a float of the daily temperature for the specified time (year +
            date) and city
        """
        assert city in self.rawdata, "provided city is not available"
        assert year in self.rawdata[city], "provided year is not available"
        assert month in self.rawdata[city][year], "provided month is not available"
        assert day in self.rawdata[city][year][month], "provided day is not available"
        return self.rawdata[city][year][month][day]

